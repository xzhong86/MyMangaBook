#!/usr/bin/env ruby

#get book from http://oreno-erohon.com

require 'yaml'
require 'ostruct'
require 'optparse'
require 'nokogiri'

load File.expand_path('../wget.rb', __FILE__)

$opts = OpenStruct.new

def get_book(url, opts)
  wget = MyWGet.new(1)
  cache = 'main-page.html'
  if not File.exist? cache
    wget.get(url, cache)
  end
  info = OpenStruct.new
  doc = Nokogiri::HTML(File.open(cache, 'r:utf-8'))
  info.url = url
  info.title = doc.title
  info.tags = doc.xpath(opts.tags_xpath).map{ |e| e.text }
  info.img_files = doc.xpath(opts.xpath).map{ |e| e['src'] }
  puts 'get tags failed' if info.tags.empty?

  File.open("info.yaml", 'w:utf-8').write(YAML.dump(info.to_h))
  return if $opts.up_info

  img_num = info.img_files.size
  info.img_files.each.with_index do |url, idx|
    puts "fetching %d/%d %s" % [ idx + 1, img_num, url ]
    fname = "%03d_%s" % [ idx, File.basename(url) ]
    wget.get(url, fname)
  end
end

def get_from(url, opts)
  if url =~ /oreno-erohon.com/
    opts.xpath = '//div[@id="main"]/article/div/section/img'
    opts.tags_xpath = '//div[@class="article-tags"][1]/ul/li/a'
  elsif url =~ /eromanga-collector.com/
    opts.xpath = '//div[@id="main"]/article/div/section/img'
    opts.tags_xpath = '//table[@class="article-all-taxs"][1]/tr[4]/td/ul/li/a'
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
  Dir.glob('book-*/info.yaml').each do |yaml|
    info = YAML.load(File.open(yaml).read)
    return File.dirname(yaml) if url == info[:url]
  end
  false
end

def check_download(url)
  dup = check_duplicate(url)
  if dup
    puts "already got it in #{dup}"
    return
  end
  pwd = Dir.pwd
  dir = create_dir($opts.dir)
  Dir.chdir dir
  get_from(url, $opts)
  Dir.chdir pwd
end

# main
$opts.dir = 'book-t-001'
OptionParser.new do |op|
  op.banner = 'getbook.rb [options] url'
  op.on('--url URL', 'get from url') { |u| $opts.url = u }
  op.on('--update-info', 'only update info file') { $opts.up_info = true }
  op.on('--dir DIR', 'get book in DIR') { |d| $opts.dir = d }
  op.on('--curdir', 'get book in current dir') { $opts.dir = nil }
  op.on('-l', '--list LIST', 'get from list') { |l| $opts.list = l }
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

