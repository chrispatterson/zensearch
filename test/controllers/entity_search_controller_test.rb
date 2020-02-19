# frozen_string_literal: true

require 'test_helper'

class EntitySearchControllerTest < ActionDispatch::IntegrationTest
  setup :do_setup

  def do_setup
    @organization = create_organization!(name: 'Slartibartfast Incorporated')
    @ticket = create_ticket!(subject: 'About Slartibartfast')
    @user = create_user!(name: 'Slartibart Fast')
  end

  test 'finds_records_by_text' do
    params = { text: 'tibart' }
    get search_path, params: params

    assert_response :success
    assert_includes response.body, 'Slartibartfast Incorporated'
    assert_includes response.body, 'About Slartibartfast'
    assert_includes response.body, 'Slartibart Fast'
  end

  test 'returns_scoped_records_by_params' do
    org_params = { org: { name: 'tibart' } }
    get search_path, params: org_params
    assert_response :success
    assert_includes response.body, 'Slartibartfast Incorporated'
    refute_includes response.body, 'About Slartibartfast'
    refute_includes response.body, 'Slartibart Fast'

    ticket_params = { ticket: { subject: 'tibart' } }
    get search_path, params: ticket_params
    assert_response :success
    refute_includes response.body, 'Slartibartfast Incorporated'
    assert_includes response.body, 'About Slartibartfast'
    refute_includes response.body, 'Slartibart Fast'

    user_params = { user: { name: 'tibart' } }
    get search_path, params: user_params
    assert_response :success
    refute_includes response.body, 'Slartibartfast Incorporated'
    refute_includes response.body, 'About Slartibartfast'
    assert_includes response.body, 'Slartibart Fast'
  end
end
