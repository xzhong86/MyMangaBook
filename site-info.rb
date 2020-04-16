
module SiteInfoMehtods
  def get_imgs(xdoc)
    xdoc.xpath(imgs_xpath).map{ |e| e['src'] }
  end
  def get_tags(xdoc)
    xdoc.xpath(tags_xpath).map{ |e| e.text }
  end
  def get_series(xdoc)
    books = xdoc.xpath(series_xpath).map{ |e| e['href'] }
    books.select{ |href| href =~ /http/ }
  end
end

class SiteInfo_A
  include SiteInfoMethods
  def initialize(url)
    fail if url !~ /oreno-erohon.com/
    @url = url
    @imgs_xpath = '//div[@id="main"]/article/div/section/img'
    @tags_xpath = '//div[@class="article-tags"][1]/ul/li/a'
    @series_xpath = '//div[@class="easy-series-toc"][1]/table/tbody/tr/td/a'
  end
end

class SiteInfo_B
  include SiteInfoMethods
  def initialize(url)
    fail if url !~ /eromanga-collector.com/
    @url = url
    @imgs_xpath = '//div[@id="main"]/article/div/section/img'
    @tags_xpath = '//table[@class="article-all-taxs"][1]/tr[4]/td/ul/li/a'
    @series_xpath = '//div[@class="easy-series-toc"][1]/table/tbody/tr/td/a'
  end
end

def getSiteInfo(url)
  if url =~ /oreno-erohon.com/
    return SiteInfo_A.new(url)
  elsif url =~ /eromanga-collector.com/
    return SiteInfo_B.new(url)
  else
    fail "unsupported site: #{url}"
  end
end
