
require 'yaml'

class MyBooksViewer
  def initialize(root)
    @root = root
    load_books()
  end
  def get_binding
    binding
  end
  attr_accessor :req

  def load_books()
    return @books if @books
    books = Dir.glob(@root + '/book-*').sort.map do |dir|
      info = File.join(dir, 'info.yaml')
      if File.exist? info
        info = YAML.load(IO.read(info))
        info = OpenStruct.new info
        info.dir = File.basename(dir)
        info
      else
        nil
      end
    end.compact
    @books = books
    books
  end

  def get_rel_book(cur, inc)
    load_books if not @books
    idx = @books.index{ |b| b.dir == cur }
    rel = idx + inc if idx
    if idx and 0 <= rel and rel < @books.size
      @books[rel].dir
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
