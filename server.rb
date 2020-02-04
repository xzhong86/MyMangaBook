#!/usr/bin/env ruby

require 'webrick'
require 'erb'
require 'ostruct'

root = Dir.pwd
#root = nil
server = WEBrick::HTTPServer.new :Port => 8081, :DocumentRoot => root

trap 'INT' do server.shutdown end

$env = OpenStruct.new({root: root})
load File.join(root, 'web-erb/functions.rb')

def open_erb(req, rsp, name)
  fname = File.join('web-erb/', name)
  if File.exist? fname
    erb = ERB.new(IO.read(fname))
    rsp.body = erb.result(binding)
  else
    rsp.body = "erb file '#{fname}' not found!"
  end
end

server.mount_proc '/' do |req, rsp|
  if req.path == '/' or req.path == '/main'
    open_erb(req, rsp, 'main.erb')
  elsif req.path == '/view'
    open_erb(req, rsp, 'view.erb')
  elsif req.path =~ /.*\.erb$/
    open_erb(req, rsp, File.basename(req.path))
  elsif req.path =~ /.*\.(jpg|png|jpeg)/
    fname = File.join('.', req.path)
    if File.exist? fname
      rsp.body = IO.read(fname)
    else
      rsp.body = "image '#{fname}' not found!"
    end
  else
    rsp.body = "Unsupport path=#{req.path}"
  end
end

server.start

