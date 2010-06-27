require File.dirname(__FILE__) + '/test_helper'

class AttrLazyTest < ActiveRecord::TestCase
  
  def setup
  end
  
  def test_create_and_find
    Article.delete_all
    Article.create(:name => 'new', :body => 'bbbbody')
    articles = Article.all
    assert_equal articles.length, 1
    assert_equal articles.first.body, 'bbbbody'
    assert_equal articles.first.name, 'new'
  end
  
  def test_select_column_list
    select = Article.select_column_list
    assert_match /\.\"name\"/, select
    assert_no_match /\.\"body\"/, select
  end
  
  def test_construct_finder_sql
    sql = Article.send(:construct_finder_sql,{})
    assert_match /\.\"name\"/, sql
    assert_no_match /\.\"body\"/, sql
    sql = Article.send(:construct_finder_sql,{:limit => 1})
    assert_match /\*/, sql
  end
  
  def test_association
    channel = Channel.new(:name => 'channel')
    channel.articles.build(:name => 'article', :body => 'bbbbboy')
    channel.save
    Channel.all
  end
end

class Article < ActiveRecord::Base
  include AttrLazy
  attr_lazy :body
  
  belongs_to :channel
end

class Channel < ActiveRecord::Base
  has_many :articles
end
