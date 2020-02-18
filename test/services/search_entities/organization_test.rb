# frozen_string_literal: true

require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  setup :do_setup

  def do_setup
    @url_org = create_organization!(url: 'https://dimsum.org')
    @external_id_org = create_organization!(
      external_id: '94441422-7a51-41a7-9ae9-911e17066sum'
    )
    @name_org = create_organization!(name: 'Omni Consumer Products')
    @details_org = create_organization!(
      details: 'Lorem ipsum dolor sit amet'
    )
    @shared_tickets_org = create_organization!(shared_tickets: true)
  end

  test 'raises_for_invalid_usage' do
    assert_raises ArgumentError do
      SearchEntities.new(Organization, 'Greetings Professor Falken.')
    end
  end

  test 'finds_by_text' do
    search_params = { text: 'sum' }
    search = SearchEntities.call(Organization, search_params)

    assert(
      [@url_org, @external_id_org, @name_org, @details_org].all? do |org|
        search.results.include? org
      end, 'Should find organizations with matching text'
    )
    refute_includes search.results, @shared_tickets_org, 'Should not find organizations without matching text'
  end

  test 'finds_by_insensitive_text' do
    insensitive_org = create_organization!(name: 'OMNI magazine')
    search_params = { text: 'omn' }
    search = SearchEntities.call(Organization, search_params)

    assert(
      [@name_org, insensitive_org].all? do |org|
        search.results.include? org
      end, 'Should find organizations with matching text regardless of case'
    )
  end

  test 'finds_empty_text_values' do
    blank_org = create_organization!(details: '')
    nil_org = create_organization!(details: nil)
    search_params = { text: '' }
    search = SearchEntities.call(Organization, search_params)

    assert_includes search.results, blank_org, 'Should find organizations by empty text'
    assert_includes search.results, nil_org, 'Should find organizations by nil text'

    assert(
      [@url_org, @external_id_org, @name_org, @details_org].all? do |org|
        search.results.exclude? org
      end, 'Should not find organizations without blank text'
    )
  end

  test 'finds_by_boolean_fields' do
    search_params = { shared_tickets: 'true' }
    search = SearchEntities.call(Organization, search_params)

    assert_includes search.results, @shared_tickets_org, 'Should find organizations by boolean value'

    assert(
      [@url_org, @external_id_org, @name_org, @details_org].all? do |org|
        search.results.exclude? org
      end, 'Should not find organizations without matching booleans'
    )
  end

  test 'finds_by_combined_fields' do
    search_params = { text: 'consume', shared_tickets: 'true' }
    search = SearchEntities.call(Organization, search_params)

    assert_includes search.results, @name_org, 'Should find organizations by text in shared context'
    assert_includes search.results, @shared_tickets_org, 'Should find organizations by boolean in shared context'
  end

  test 'finds_by_tags' do
    tag_name = 'Amaryllis'
    tag_org = create_organization!
    tag_org.tags << Tag.where(name: tag_name).first_or_create!
    search_params = { tags: tag_name }
    search = SearchEntities.call(Organization, search_params)

    assert_includes search.results, tag_org, 'Should find organizations by tag'
  end

  test 'finds_by_domains' do
    domain_name = 'brawndo.com'
    domain_org = create_organization!
    domain_org.domain_names << DomainName.where(name: domain_name).first_or_create!
    search_params = { domain_names: domain_name }
    search = SearchEntities.call(Organization, search_params)

    assert_includes search.results, domain_org, 'Should find organizations by tag'
  end
end
