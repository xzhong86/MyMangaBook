
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

  def load_favourite
    fav = if File.exists? @bookdir + '/favourite.yaml'
            YAML.load(IO.read(@bookdir + '/favourite.yaml'))
          else
            Hash.new(nil)
          end
    @books.each do |book|
      if fav_book = fav[book.dir]
        book.nlike = fav_book[:like] || 0
        book.nview = fav_book[:view] || 1
      else
        book.nlike = 0
        book.nview = 0
      end
    end
  end
  def store_favourite
    fav = {}
    @books.each do |book|
      if book.nlike != 0 or book.nview != 0
        fav[book.dir] = { like: book.nlike, view: book.nview }
      end
    end
    IO.write(@bookdir + '/favourite.yaml', YAML.dump(fav))
  end

  def load_books()
    return @books if @books
    @books = Dir.glob(@bookdir + '/book-*').sort.map do |dir|
      info = File.join(dir, 'info.yaml')
      if File.exist? info
        info = YAML.load(IO.read(info))
        info = OpenStruct.new info
        info.dir = File.basename(dir)
        images = Dir.glob(dir + '/*.jpg')
        images = Dir.glob(dir + '/*.png') if images.empty?
        info.images = images.map do |img|
          info.dir + '/' + File.basename(img)
        end.sort
        info
      else
        nil
      end
    end.compact
    @books.each.with_index{ |b,i| b.id = 'b' + i.to_s }
    load_favourite()
    @books
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

  def do_async(req, rsp)
    if req.query['like']
      book = get_book(req.query['book'])
      inc = req.query['like'].to_i
      book.nlike += 1 if inc > 0 and book.nlike < 9
      book.nlike -= 1 if inc < 0 and book.nlike > -3
      rsp.body = book.nlike.to_s
      store_favourite
    end
  end
  def inc_view(book)
    book.nview += 1
    store_favourite
  end
end
