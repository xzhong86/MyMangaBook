#!/usr/bin/env ruby
# coding: utf-8

require 'open-uri'

class MyWGet
  def initialize(time_stride)
    @last_time = Time.now
    @time_stride = time_stride
  end
  def check_sleep
    dif = Time.now - @last_time
    if dif < @time_stride
      if sleep(@time_stride - dif) == 0
        return
      end
    end
    @last_time = Time.now
  end
  def get(from, to)
    begin
      open(from) do |fin|
        fout = open(to, 'w')
        fout.write(fin.read)
      end
      check_sleep
      return true
    rescue OpenURI::HTTPError
      return false
    end
  end
end


