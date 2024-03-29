#!/usr/bin/env ruby

require 'webrick'
require 'erb'
require 'ostruct'
require 'open-uri'

load File.join(File.dirname(__FILE__), 'web-erb/functions.rb')
$books = nil

def open_erb(req, rsp, name)
  books = $books;
  fname = File.join('web-erb/', name)
  if File.exist? fname
    erb = ERB.new(IO.read(fname))
    books.req = req;
    rsp.body = erb.result(books.get_binding)
  else
    rsp.body = "erb file '#{fname}' not found!"
  end
end

def start_server(docroot, bookdir)
  port = 8083
  ip   = IO.popen("hostname -I").read.split.first
  puts "start server on http://#{ip}:#{port} ..."
  server = WEBrick::HTTPServer.new :Port => port, :DocumentRoot => docroot
  server.mount_proc '/' do |req, rsp|
    if req.path == '/' or req.path == '/main'
      open_erb(req, rsp, 'main.erb')
    elsif req.path == '/view'
      open_erb(req, rsp, 'view.erb')
    elsif req.path == '/async'
      $books.do_async(req, rsp)

    elsif req.path =~ /.*\.erb$/
      open_erb(req, rsp, File.basename(req.path))

    elsif req.path =~ /\bjquery.min.js$/
      rsp.body = IO.read('web-erb/jquery.1.10.2.min.js')

    elsif req.path =~ /.*\.(jpg|png|jpeg)/
      fname = File.join(bookdir, req.path)
      if File.exist? fname
        rsp.body = IO.read(fname)
      else
        rsp.body = "image '#{fname}' not found!"
      end
    else
      puts "access unsupport path='#{req.path}'"
      rsp.body = "Unsupport path=#{req.path}"
    end
  end

  trap 'INT' do
    server.shutdown
    $books.store_favourite
  end
  server.start
end


# main
root = Dir.pwd
$books = MyBooksViewer.new(root + '/books')
start_server(root, root + '/books')
