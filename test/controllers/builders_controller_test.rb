require 'test_helper'

class BuildersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @builder = builders(:one)
  end

  test "should get index" do
    get builders_url
    assert_response :success
  end

  test "should get new" do
    get new_builder_url
    assert_response :success
  end

  test "should create builder" do
    assert_difference('Builder.count') do
      post builders_url, params: { builder: {  } }
    end

    assert_redirected_to builder_url(Builder.last)
  end

  test "should show builder" do
    get builder_url(@builder)
    assert_response :success
  end

  test "should get edit" do
    get edit_builder_url(@builder)
    assert_response :success
  end

  test "should update builder" do
    patch builder_url(@builder), params: { builder: {  } }
    assert_redirected_to builder_url(@builder)
  end

  test "should destroy builder" do
    assert_difference('Builder.count', -1) do
      delete builder_url(@builder)
    end

    assert_redirected_to builders_url
  end
end
