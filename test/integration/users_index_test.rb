require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin= users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin icluding pagination and delete link" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    User.paginate(page: 1).each do |u|
      assert_select 'a[href=?]', user_path(u), text: u.name
      assert_select 'a[href=?]', user_path(u), text: "DELETE" if u != @admin
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
    assert_redirected_to :index
  end

  test 'index as non admin' do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'DELETE', count: 0
  end

end
