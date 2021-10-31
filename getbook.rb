#!/usr/bin/env ruby
# coding: utf-8

#get book from http://oreno-erohon.com

require 'yaml'
require 'ostruct'
require 'optparse'
require 'nokogiri'
require 'cgi'

load File.expand_path('../wget.rb', __FILE__)

$opts = OpenStruct.new

def get_book(url, opts)
  wget = MyWGet.new(opts.fast ? nil : 1, 3)
  cache = 'main-page.html'
  if not File.exist? cache
    wget.get(url, cache)
  end
  info = OpenStruct.new
  doc = Nokogiri::HTML(File.open(cache, 'r:utf-8'))
  info.url = url
  info.title = doc.title
  if opts.tags_xpath
    info.tags = doc.xpath(opts.tags_xpath).map{ |e| e.text }
  else
    info.tags = [ ]
  end
  info.img_files = doc.xpath(opts.xpath).map{ |e| e['data-original'] }
  puts 'get tags failed' if info.tags.empty?

  File.open("info.yaml", 'w:utf-8').write(YAML.dump(info.to_h))
  return if $opts.up_info

  img_num = info.img_files.size
  info.img_files.each.with_index do |url, idx|
    puts "fetching %d/%d %s" % [ idx + 1, img_num, url ]
    fname = "%03d_%s" % [ idx, opts.basename.call(url) ]
    wget.get(url, fname) if not File.exist? fname
  end
end

def get_from(url, opts)
  opts.basename = proc { |u| File.basename(u) }
  if url =~ /oreno-erohon.com/
    opts.xpath ||= '//div[@id="main"]/article/div/section/img'
    opts.tags_xpath ||= '//div[@class="article-tags"][1]/ul/li/a'
  elsif url =~ /eromanga-collector.com/
    opts.xpath ||= '//div[@id="main"]/article/div/section/img'
    opts.tags_xpath ||= '//table[@class="article-all-taxs"][1]/tr[4]/td/ul/li/a'
  elsif url =~ /xn--qexm24f3mc.xyz/
    opts.xpath ||= '//div[@id="contentimg"]/ul/li/img'
    opts.basename = proc { |u| File.basename(CGI.unescape(u)) }
  else
    fail "unsupported site: #{url}"
  end
  get_book(url, opts)
end

def create_dir(dir)
  dir.succ! while Dir.exist? dir
  puts "mkdir " + dir
  Dir.mkdir dir
  dir
end

def check_duplicate(url)
  Dir.glob('books/book-*/info.yaml').each do |yaml|
    info = YAML.load(File.open(yaml).read)
    return File.dirname(yaml) if url == info[:url]
  end
  false
end

def check_download(url)
  dup = check_duplicate(url)
  if dup and not $opts.continue
    puts "already got it in #{dup}"
    return
  end
  if $opts.continue and not dup
    puts "continue on book which not exist."
    return
  end
  if $opts.no_download
    puts "missing book: #{url}"
    return
  end
  pwd = Dir.pwd
  dir = dup ? dup : create_dir($opts.dir)
  Dir.chdir dir
  get_from(url, $opts)
  Dir.chdir pwd
end

# main
$opts.dir = 'books/book-t-001'
OptionParser.new do |op|
  op.banner = 'getbook.rb [options] url'
  op.on('--url URL', 'get from url') { |u| $opts.url = u }
  op.on('--update-info', 'only update info file') { $opts.up_info = true }
  op.on('--dir DIR', 'get book in DIR') { |d| $opts.dir = d }
  op.on('--curdir', 'get book in current dir') { $opts.dir = nil }
  op.on('-C', '--continue', 'continue on exist book') { $opts.continue = true }
  op.on('-F', '--fast', 'fast mode') { $opts.fast = true }
  op.on('-l', '--list LIST', 'get from list') { |l| $opts.list = l }
  op.on('-x', '--xpath xpath', 'img from xpath') { |x| $opts.xpath = x }
  op.on('-t', '--tags-xpath xt', 'tags xpath') { |x| $opts.tags_xpath = x }
  op.on('-n', '--no-download', 'only check') { $opts.no_download = true }
end.parse!

if $opts.up_info and not $opts.url
  puts 'read info.yaml'
  info = YAML.load(File.open('info.yaml').read)
  $opts.url = info[:url]
end


if $opts.list
  # read from list
  IO.readlines($opts.list).each do |url|
    if url =~ /http/
      check_download(url.chomp)
    end
  end
else
  fail "need url" if not $opts.url and ARGV.empty?
  $opts.url ||= ARGV[0]
  check_download($opts.url)
end

