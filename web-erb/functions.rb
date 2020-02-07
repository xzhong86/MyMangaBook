
require 'yaml'

class MyBooksViewer
  def initialize(root)
    @bookdir = root
    load_books()
  end
  def get_binding
    binding
  end
  attr_accessor :req

  def load_books()
    return @books if @books
    books = Dir.glob(@bookdir + '/book-*').sort.map do |dir|
      info = File.join(dir, 'info.yaml')
      if File.exist? info
        info = YAML.load(IO.read(info))
        info = OpenStruct.new info
        info.dir = File.basename(dir)
        info.images = Dir.glob(info.dir + '/*.jpg').sort
        info
      else
        nil
      end
    end.compact
    books.each.with_index{ |b,i| b.id = 'b' + i.to_s }
    @books = books
    books
  end
  def load_tags()
    return @tags if @tags
    @tags = Hash.new(0)
    @books.each do |book|
      book.tags.each { |t| @tags[t] += 1 }
    end
    @tags
  end

  def get_book(_book)
    book = nil
    book ||= @books.find{ |b| b.id == _book }
    book ||= @books.find{ |b| b.dir == _book }
    book ||= @books.find{ |b| b.title == _book }
    book
  end
  def get_rel_book(cur, inc)
    load_books if not @books
    idx = @books.index{ |b| b.id == cur.id }
    rel = idx + inc if idx
    if idx and 0 <= rel and rel < @books.size
      @books[rel].id
    else
      nil
    end
  end
  def get_next_book(cur)
    get_rel_book(cur, 1)
  end
  def get_prev_book(cur)
    get_rel_book(cur, -1)
  end

end
