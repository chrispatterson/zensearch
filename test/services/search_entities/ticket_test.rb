# frozen_string_literal: true

require 'test_helper'

class TicketTest < ActiveSupport::TestCase
  setup :do_setup

  def do_setup
    @id_ticket = create_ticket!(id: 'ed50f42a-6rem-4591-ac64-41a4c49c6e29')
    @url_ticket = create_ticket!(url: 'https://premiere.org')
    @external_id_ticket = create_ticket!(
      external_id: '94441422-7a51-41a7-9ae9-911e17066rem'
    )
    @subject_ticket = create_ticket!(subject: 'Remarkable Concepts')
    @description_ticket = create_ticket!(
      description: 'Lorem ipsum dolor sit amet'
    )
    @incidents_ticket = create_ticket!(has_incidents: true)
  end

  test 'raises_for_invalid_usage' do
    assert_raises ArgumentError do
      SearchEntities.new(Ticket, 'Greetings Professor Falken.')
    end
  end

  test 'finds_by_text' do
    search_params = { text: 'rem' }
    search = SearchEntities.call(Ticket, search_params)

    assert(
      [@id_ticket, @url_ticket, @external_id_ticket, @subject_ticket, @description_ticket].all? do |ticket|
        search.results.include? ticket
      end, 'Should find tickets with matching text'
    )
    refute_includes search.results, @incidents_ticket, 'Should not find tickets without matching text'
  end

  test 'finds_by_insensitive_text' do
    insensitive_ticket = create_ticket!(subject: 'CONTRA .')
    search_params = { text: 'con' }
    search = SearchEntities.call(Ticket, search_params)

    assert(
      [@subject_ticket, insensitive_ticket].all? do |org|
        search.results.include? org
      end, 'Should find tickets with matching text regardless of case'
    )
  end

  test 'finds_empty_text_values' do
    blank_ticket = create_ticket!(description: '')
    nil_ticket = create_ticket!(description: nil)
    search_params = { text: '' }
    search = SearchEntities.call(Ticket, search_params)

    assert_includes search.results, blank_ticket, 'Should find tickets by empty text'
    assert_includes search.results, nil_ticket, 'Should find tickets by nil text'

    assert(
      [@id_ticket, @url_ticket, @external_id_ticket, @subject_ticket, @description_ticket].all? do |org|
        search.results.exclude? org
      end, 'Should not find tickets without blank text'
    )
  end

  test 'finds_by_date' do
    tomorrow = (DateTime.now + 1.day).utc
    tomorrow_ticket = create_ticket!(due_at: tomorrow)
    search_params = { due_at: tomorrow.to_date }
    search = SearchEntities.call(Ticket, search_params)

    assert_includes search.results, tomorrow_ticket, 'Should find tickets by date'

    assert(
      [@id_ticket, @url_ticket, @external_id_ticket, @subject_ticket, @description_ticket].all? do |org|
        search.results.exclude? org
      end, 'Should not find tickets without matching date'
    )
  end

  test 'finds_by_enums' do
    priority_ticket = create_ticket!(priority: :high)
    search_params = { priority: 'high' }
    search = SearchEntities.call(Ticket, search_params)

    assert_includes search.results, priority_ticket, 'Should find tickets by enum'

    assert(
      [@id_ticket, @url_ticket, @external_id_ticket, @subject_ticket, @description_ticket].all? do |org|
        search.results.exclude? org
      end, 'Should not find tickets without matching enum'
    )
  end

  test 'finds_by_other_fields' do
    other_submitter = create_user!(id: SecureRandom.random_number(100) + 9_999_999_999)
    other_ticket = create_ticket!(submitter: other_submitter)
    search_params = { submitter_id: other_submitter.id }
    search = SearchEntities.call(Ticket, search_params)

    assert_includes search.results, other_ticket, 'Should find tickets by enum'

    assert(
      [@id_ticket, @url_ticket, @external_id_ticket, @subject_ticket, @description_ticket].all? do |org|
        search.results.exclude? org
      end, 'Should not find tickets without matching other field'
    )
  end
end
