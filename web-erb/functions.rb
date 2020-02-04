
require 'yaml'

def load_books()
  return $env.books if $env.books
  books = Dir.glob($env.root + '/book-*').sort.map do |dir|
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
  $env.books = books
  books
end

def get_next_book(cur)
  load_books if not $env.books
  idx = $env.books.index{ |b| b.dir == cur }
  if idx and idx + 1 < cur.size
    $env.books[idx+1].dir
  else
    nil
  end
end

def get_prev_book(cur)
  load_books if not $env.books
  idx = $env.books.index{ |b| b.dir == cur }
  if idx and idx - 1 >= 0
    $env.books[idx-1].dir
  else
    nil
  end
end
