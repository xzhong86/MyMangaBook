#!/usr/bin/env ruby
# coding: utf-8

require 'open-uri'

class MyWGet
  def initialize(time_stride, retry_times = 0)
    @last_time = Time.now
    @time_stride = time_stride
    @retry_times = retry_times
  end
  def check_sleep
    return if not @time_stride
    dif = Time.now - @last_time
    if dif < @time_stride
      if sleep(@time_stride - dif) == 0
        return
      end
    end
    @last_time = Time.now
  end
  def get(from, to)
    nr_retry = 0
    loop do
      begin
        URI.open(from) do |fin|
          fout = open(to, 'w')
          fout.write(fin.read)
        end
        check_sleep
        return true
      rescue OpenURI::HTTPError
        if nr_retry >= @retry_times
          return false
        else
          sleep 1 # sleep before retry
        end
      end
    end
  end
end


