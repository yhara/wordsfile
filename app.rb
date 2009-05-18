require 'rubygems'
require 'ramaze'
require 'datamapper'

# モデル
DataMapper.setup(:default, "sqlite3://#{__DIR__('words.db')}")
class Word
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :description, Text

  validates_is_unique :name
end
DataMapper.auto_upgrade!

# コントローラ
class Words < Ramaze::Controller
  map '/'
  engine :ERB
  layout 'default'

  def index
    @words = Word.all
  end

  def new
  end

  def create
    word = Word.create({
      :name => request['name'],
      :description => request['description']
    })
    if word
      redirect r(:show, word.id)
    else
      redirect_referer
    end
  end

  def show(id)
    @word = Word.get(id)
  end

  def delete(id)
    redirect_referer unless request.post?
    word = Word.get(id)
    if word
      word.destroy
      redirect r(:index)
    else
      redirect_referer
    end
  end

  def random
    at = rand(Word.count)
    @word = Word.first(:offset => at)
    render_view :show
  end
end

Ramaze.start :port => 7999
