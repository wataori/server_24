require 'test_helper'

class KeyPhrasesControllerTest < ActionController::TestCase
  setup do
    @key_phrase = key_phrases(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:key_phrases)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create key_phrase" do
    assert_difference('KeyPhrase.count') do
      post :create, key_phrase: {  }
    end

    assert_redirected_to key_phrase_path(assigns(:key_phrase))
  end

  test "should show key_phrase" do
    get :show, id: @key_phrase
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @key_phrase
    assert_response :success
  end

  test "should update key_phrase" do
    patch :update, id: @key_phrase, key_phrase: {  }
    assert_redirected_to key_phrase_path(assigns(:key_phrase))
  end

  test "should destroy key_phrase" do
    assert_difference('KeyPhrase.count', -1) do
      delete :destroy, id: @key_phrase
    end

    assert_redirected_to key_phrases_path
  end
end
