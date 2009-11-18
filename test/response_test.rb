require 'test_unit_test_case'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr-ext')
require 'helper'

class RSolrExtResponseTest < Test::Unit::TestCase
  
  test 'base response class' do
    raw_response = eval(mock_query_response)
    r = RSolr::Ext::Response::Base.new(raw_response)
    assert r.respond_to?(:header)
    assert r.ok?
  end
  
  test 'standard response class' do
    raw_response = eval(mock_query_response)
    r = RSolr::Ext::Response::Base.new(raw_response)
    assert r.respond_to?(:response)
    assert r.ok?
    assert_equal 11, r.docs.size
    assert_equal 'EXPLICIT', r.params[:echoParams]
    #
    assert r.kind_of?(RSolr::Ext::Response::Docs)
    assert r.kind_of?(RSolr::Ext::Response::Facets)
  end
  
  test 'standard response doc ext methods' do
    raw_response = eval(mock_query_response)
    r = RSolr::Ext::Response::Base.new(raw_response)
    doc = r.docs.first
    assert doc.has?(:cat, /^elec/)
    assert ! doc.has?(:cat, 'elec')
    assert doc.has?(:cat, 'electronics')
    
    assert 'electronics', doc.get(:cat)
    assert_nil doc.get(:xyz)
    assert_equal 'def', doc.get(:xyz, :default=>'def')
  end
  
  test 'Response::Standard facets' do
    raw_response = eval(mock_query_response)
    r = RSolr::Ext::Response::Base.new(raw_response)
    assert_equal 2, r.facets.size
    
    field_names = r.facets.collect{|facet|facet.name}
    assert field_names.include?('cat')
    assert field_names.include?('manu')
    
    first_facet = r.facets.first
    assert_equal 'cat', first_facet.name
    
    assert_equal 10, first_facet.items.size
    
    expected = first_facet.items.collect do |item|
      item.value + ' - ' + item.hits.to_s
    end.join(', ')
    assert_equal "electronics - 14, memory - 3, card - 2, connector - 2, drive - 2, graphics - 2, hard - 2, monitor - 2, search - 2, software - 2", expected
    
    r.facets.each do |facet|
      assert facet.respond_to?(:name)
      facet.items.each do |item|
        assert item.respond_to?(:value)
        assert item.respond_to?(:hits)
      end
    end
    
  end
  
  test 'response::standard facet_by_field_name' do
    raw_response = eval(mock_query_response)
    r = RSolr::Ext::Response::Base.new(raw_response)
    facet = r.facet_by_field_name('cat')
    assert_equal 'cat', facet.name
  end
  
end