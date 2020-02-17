# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup :do_setup

  def do_setup
    @url_user = create_user!(url: 'https://sit.edu')
    @external_id_user = create_user!(
      external_id: '94441422-7a51-4sit-9ae9-911e17066066'
    )
    @name_user = create_user!(name: 'Situation Nominal')
    @signature_user = create_user!(
      signature: 'Lorem ipsum dolor sit amet'
    )
    @inactive_user = create_user!(active: false)
  end

  test 'raises_for_invalid_usage' do
    assert_raises ArgumentError do
      SearchEntities.new(User, 'Greetings Professor Falken.')
    end
    assert_raises ArgumentError do
      SearchEntities.new(User, nonexistent: 'oops')
    end
  end

  test 'finds_by_text' do
    search_params = { text: 'sit' }
    search = SearchEntities.call(User, search_params)

    assert(
      [@url_user, @external_id_user, @name_user, @signature_user].all? do |org|
        search.results.include? org
      end, 'Should find users with matching text'
    )
    refute_includes search.results, @inactive_user, 'Should not find users without matching text'
  end

  test 'finds_by_insensitive_text' do
    insensitive_user = create_user!(name: 'OMNoM')
    search_params = { text: 'nom' }
    search = SearchEntities.call(User, search_params)

    assert(
      [@name_user, insensitive_user].all? do |org|
        search.results.include? org
      end, 'Should find users with matching text regardless of case'
    )
  end

  test 'finds_empty_text_values' do
    blank_user = create_user!(signature: '')
    nil_user = create_user!(signature: nil)
    search_params = { text: '' }
    search = SearchEntities.call(User, search_params)

    assert_includes search.results, blank_user, 'Should find users by empty text'
    assert_includes search.results, nil_user, 'Should find users by nil text'

    assert(
      [@url_user, @external_id_user, @name_user, @signature_user].all? do |org|
        search.results.exclude? org
      end, 'Should not find users without blank text'
    )
  end

  test 'finds_by_boolean_fields' do
    search_params = { active: 'false' }
    search = SearchEntities.call(User, search_params)

    assert_includes search.results, @inactive_user, 'Should find users by boolean value'

    assert(
      [@url_user, @external_id_user, @name_user, @signature_user].all? do |org|
        search.results.exclude? org
      end, 'Should not find users without matching booleans'
    )
  end

  test 'finds_by_combined_fields' do
    search_params = { text: 'sit', active: 'false' }
    search = SearchEntities.call(User, search_params)

    assert_includes search.results, @name_user, 'Should find users by text in shared context'
    assert_includes search.results, @inactive_user, 'Should find users by boolean in shared context'
  end
end
