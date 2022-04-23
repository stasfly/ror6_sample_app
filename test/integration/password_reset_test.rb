require "test_helper"

class PasswordResetTest < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test 'password_reset' do
    get login_path
    assert_template 'sessions/new'
    assert_select "a[href=?]", "/password_resets/new"
    get new_password_reset_path
    assert_template 'password_resets/new'
    # Invalid email
    post password_resets_path, params: {password_reset: {email: ""}}
    assert_not flash.empty?
    assert_template 'password_resets/new'
    # Valid email
    post password_resets_path, params: {password_reset: {email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # Password reset form
    user = assigns(:user)
    # Wrong imail
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    #Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    #right email, wrong token
    get edit_password_reset_path("wrong token", email: user.email)
    assert_redirected_to root_url
    #Right email and token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    #invalid password and confirmation
    patch password_reset_path(user.reset_token), 
          params: {email: user.email, 
                   user: {password: "qwerty", 
                          password_confirmation: 'asdfgh' } }
    assert_select 'div#error_explanation'
    #Empty password
    patch password_reset_path(user.reset_token),
          params: {email: user.email, 
                   user: {password: '', 
                          password_confirmation: '' } }
    assert_select 'div#error_explanation'
    #valid password and confirmation
    patch password_reset_path(user.reset_token),
          params: {email: user.email, 
                   user: {password: 'qwerty', 
                          password_confirmation: 'qwerty' } }
    assert is_logged_in?
    assert_nil user.reload.reset_digest
    assert_not flash.empty?
    assert_redirected_to user
  end

  test 'Expired token' do
    get new_password_reset_path
    post password_resets_path, params: {password_reset: {email: @user.email } }
    
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
          params: {email: @user.email, 
                  user: {password: 'qwerty', 
                         password_confirmation: 'qwerty' } }
    assert_response :redirect
    follow_redirect!
    assert_match 'expired', response.body
  end

end
