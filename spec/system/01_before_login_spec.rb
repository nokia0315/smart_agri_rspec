require 'rails_helper'

describe '[STEP1] ログイン前のテスト' do
  describe 'トップ画面のテスト' do
    before do
      visit root_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/'
      end
      it 'Log inリンクが表示される: 左上から5番目のリンクが「Log in」である' do
        log_in_link = find_all('a')[5].native.inner_text
        expect(log_in_link).to match(/log in/i)
      end
      it 'Log inリンクの内容が正しい' do
        log_in_link = find_all('a')[5].native.inner_text
        expect(page).to have_link log_in_link, href: new_user_session_path
      end
      it 'Sign Upリンクが表示される: 左上から6番目のリンクが「Sign Up」である' do
        sign_up_link = find_all('a')[6].native.inner_text
        expect(sign_up_link).to match(/sign up/i)
      end
      it 'Sign Upリンクの内容が正しい' do
        sign_up_link = find_all('a')[6].native.inner_text
        expect(page).to have_link sign_up_link, href: new_user_registration_path
      end
    end
  end

  describe 'アバウト画面のテスト' do
    before do
      visit '/about'
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/about'
      end
    end
  end

  describe 'ヘッダーのテスト: ログインしていない場合' do
    before do
      visit root_path
    end

    context '表示内容の確認' do
      it 'タイトルが表示される' do
        expect(page).to have_content 'SmartAgri'
      end
      it 'Homeリンクが表示される: 左上から1番目のリンクが「Home」である' do
        home_link = find_all('a')[1].native.inner_text
        expect(home_link).to match(/home/i)
      end
      it 'Aboutリンクが表示される: 左上から2番目のリンクが「About」である' do
        about_link = find_all('a')[2].native.inner_text
        expect(about_link).to match(/about/i)
      end
      it 'sign upリンクが表示される: 左上から3番目のリンクが「sign up」である' do
        signup_link = find_all('a')[3].native.inner_text
        expect(signup_link).to match(/sign up/i)
      end
      it 'loginリンクが表示される: 左上から4番目のリンクが「login」である' do
        login_link = find_all('a')[4].native.inner_text
        expect(login_link).to match(/login/i)
      end
    end

    context 'リンクの内容を確認' do
      subject { current_path }

      it 'Homeを押すと、トップ画面に遷移する' do
        home_link = find_all('a')[1].native.inner_text
        home_link = home_link.delete(' ')
        home_link.gsub!(/\n/, '')
        click_link home_link
        is_expected.to eq '/'
      end
      it 'Aboutを押すと、アバウト画面に遷移する' do
        about_link = find_all('a')[2].native.inner_text
        about_link = about_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link about_link
        is_expected.to eq '/about'
      end
      it 'sign upを押すと、新規登録画面に遷移する' do
        signup_link = find_all('a')[3].native.inner_text
        signup_link = signup_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link signup_link
        is_expected.to eq '/users/sign_up'
      end
      it 'loginを押すと、ログイン画面に遷移する' do
        login_link = find_all('a')[4].native.inner_text
        login_link = login_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link login_link
        is_expected.to eq '/users/sign_in'
      end
      it '農業者はこちらを押すと、新規登録画面に遷移する' do
        f_signup_link = find_all('a')[5].native.inner_text
        f_signup_link = f_signup_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link f_signup_link
        is_expected.to eq '/farmers/sign_up'
      end
    end
  end

  describe 'ユーザ新規登録のテスト' do
    before do
      visit new_user_registration_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/sign_up'
      end
      it '「新規会員登録」と表示される' do
        expect(page).to have_content '新規会員登録'
      end
      it 'first_nameフォームが表示される' do
        expect(page).to have_field 'user[first_name]'
      end
      it 'last_nameフォームが表示される' do
        expect(page).to have_field 'user[last_name]'
      end
      it 'kana_first_nameフォームが表示される' do
        expect(page).to have_field 'user[kana_first_name]'
      end
      it 'kana_last_nameフォームが表示される' do
        expect(page).to have_field 'user[kana_last_name]'
      end
      it 'emailフォームが表示される' do
        expect(page).to have_field 'user[email]'
      end
      it 'postal_codeフォームが表示される' do
        expect(page).to have_field 'user[postal_code]'
      end
      it 'residenceフォームが表示される' do
        expect(page).to have_field 'user[residence]'
      end
      it 'passwordフォームが表示される' do
        expect(page).to have_field 'user[password]'
      end
      it 'password_confirmationフォームが表示される' do
        expect(page).to have_field 'user[password_confirmation]'
      end
      it '新規登録ボタンが表示される' do
        expect(page).to have_button '新規登録'
      end
    end

    context 'ユーザー新規登録成功のテスト' do
      before do
        fill_in 'user[first_name]', with: Faker::Lorem.characters(number: 20)
        fill_in 'user[last_name]', with: Faker::Lorem.characters(number: 20)
        fill_in 'user[email]', with: Faker::Internet.email
        fill_in 'user[password]', with: 'password'
        fill_in 'user[password_confirmation]', with: 'password'
      end

      it '正しく新規登録される' do
        expect { click_button '新規登録' }.to change(User.all, :count).by(1)
      end
      it '新規登録後のリダイレクト先が、新規登録できたユーザの詳細画面になっている' do
        click_button '新規登録'
        expect(current_path).to eq '/users/' + User.last.id.to_s
      end
    end
  end

  describe 'ユーザログイン' do
    let(:user) { create(:user) }

    before do
      visit new_user_session_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/sign_in'
      end
      it '「Log in」と表示される' do
        expect(page).to have_content 'Log in'
      end
      it 'emailフォームが表示される' do
        expect(page).to have_field 'user[email]'
      end
      it 'passwordフォームが表示される' do
        expect(page).to have_field 'user[password]'
      end
      it '新規登録ボタンが表示される' do
        expect(page).to have_button '新規登録'
      end
    end

    context 'ログイン成功のテスト' do
      before do
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button '新規登録'
      end

      it 'ログイン後のリダイレクト先が、ログインしたユーザの詳細画面になっている' do
        expect(current_path).to eq '/users/' + user.id.to_s
      end
    end

    context 'ログイン失敗のテスト' do
      before do
        fill_in 'user[email]', with: ''
        fill_in 'user[password]', with: ''
        click_button '新規登録'
      end

      it 'ログインに失敗し、ログイン画面にリダイレクトされる' do
        expect(current_path).to eq '/users/sign_in'
      end
    end
  end

  describe 'ヘッダーのテスト: ログインしている場合' do
    let(:user) { create(:user) }

    before do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
    end

    context 'ヘッダーの表示を確認' do
      it 'タイトルが表示される' do
        expect(page).to have_content 'SmartAgri'
      end
      it 'topリンクが表示される: 左上から1番目のリンクが「top」である' do
        top_link = find_all('a')[1].native.inner_text
        expect(top_link).to match(/top/)
      end
      it 'マイページリンクが表示される: 左上から1番目のリンクが「マイページ」である' do
        users_link = find_all('a')[2].native.inner_text
        expect(users_link).to match(/users/i)
      end
      it '求人一覧リンクが表示される: 左上から3番目のリンクが「求人一覧」である' do
        job_offers_link = find_all('a')[3].native.inner_text
        expect(job_offers_link).to match(/job_offers/i)
      end
      it 'log outリンクが表示される: 左上から4番目のリンクが「ログアウト」である' do
        logout_link = find_all('a')[4].native.inner_text
        expect(logout_link).to match(/logout/i)
      end
    end
  end

  describe 'ユーザログアウトのテスト' do
    let(:user) { create(:user) }

    before do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
      logout_link = find_all('a')[4].native.inner_text
      logout_link = logout_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
      click_link logout_link
    end

    context 'ログアウト機能のテスト' do
      it '正しくログアウトできている: ログアウト後のリダイレクト先においてAbout画面へのリンクが存在する' do
        expect(page).to have_link '', href: '/about'
      end
      it 'ログアウト後のリダイレクト先が、トップになっている' do
        expect(current_path).to eq '/'
      end
    end
  end

  describe '農業者新規登録のテスト' do
    before do
      visit new_farmer_registration_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/farmers/sign_up'
      end
      it '「新規農業者登録」と表示される' do
        expect(page).to have_content '新規農業者登録'
      end
      it 'first_nameフォームが表示される' do
        expect(page).to have_field 'farmer[first_name]'
      end
      it 'last_nameフォームが表示される' do
        expect(page).to have_field 'farmer[last_name]'
      end
      it 'kana_first_nameフォームが表示される' do
        expect(page).to have_field 'farmer[kana_first_name]'
      end
      it 'kana_last_nameフォームが表示される' do
        expect(page).to have_field 'farmer[kana_last_name]'
      end
      it 'emailフォームが表示される' do
        expect(page).to have_field 'farmer[email]'
      end
      it 'postal_codeフォームが表示される' do
        expect(page).to have_field 'farmer[postal_code]'
      end
      it 'residenceフォームが表示される' do
        expect(page).to have_field 'farmer[residence]'
      end
      it 'passwordフォームが表示される' do
        expect(page).to have_field 'farmer[password]'
      end
      it 'password_confirmationフォームが表示される' do
        expect(page).to have_field 'farmer[password_confirmation]'
      end
      it '新規登録ボタンが表示される' do
        expect(page).to have_button '新規登録'
      end
    end

    context '新規登録成功のテスト' do
      before do
        fill_in 'farmer[first_name]', with: Faker::Lorem.characters(number: 20)
        fill_in 'farmer[last_name]', with: Faker::Lorem.characters(number: 20)
        fill_in 'farmer[email]', with: Faker::Internet.email
        fill_in 'farmer[password]', with: 'password'
        fill_in 'farmer[password_confirmation]', with: 'password'
      end

      it '正しく新規登録される' do
        expect { click_button '新規登録' }.to change(farmer.all, :count).by(1)
      end
      it '新規登録後のリダイレクト先が、新規登録できた農業者の詳細画面になっている' do
        click_button '新規登録'
        expect(current_path).to eq '/farmers/' + farmer.last.id.to_s
      end
    end
  end

  describe '農業者ログイン' do
    let(:farmer) { create(:farmer) }

    before do
      visit new_farmer_session_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/farmers/sign_in'
      end
      it '「Log in」と表示される' do
        expect(page).to have_content 'Log in'
      end
      it 'emailフォームが表示される' do
        expect(page).to have_field 'farmer[email]'
      end
      it 'passwordフォームが表示される' do
        expect(page).to have_field 'farmer[password]'
      end
      it '新規登録ボタンが表示される' do
        expect(page).to have_button '新規登録'
      end
    end

    context 'ログイン成功のテスト' do
      before do
        fill_in 'farmer[email]', with: farmer.email
        fill_in 'farmer[password]', with: farmer.password
        click_button '新規登録'
      end

      it 'ログイン後のリダイレクト先が、ログインした農業者の詳細画面になっている' do
        expect(current_path).to eq '/farmers/' + farmer.id.to_s
      end
    end

    context 'ログイン失敗のテスト' do
      before do
        fill_in 'farmer[email]', with: ''
        fill_in 'farmer[password]', with: ''
        click_button '新規登録'
      end

      it 'ログインに失敗し、ログイン画面にリダイレクトされる' do
        expect(current_path).to eq '/farmers/sign_in'
      end
    end
  end

  describe 'ヘッダーのテスト: ログインしている場合' do
    let(:farmer) { create(:farmer) }

    before do
      visit new_farmer_session_path
      fill_in 'farmer[email]', with: farmer.email
      fill_in 'farmer[password]', with: farmer.password
      click_button 'ログイン'
    end

    context 'ヘッダーの表示を確認' do
      it 'タイトルが表示される' do
        expect(page).to have_content 'SmartAgri'
      end
      it 'topリンクが表示される: 左上から1番目のリンクが「top」である' do
        top_link = find_all('a')[1].native.inner_text
        expect(top_link).to match(/top/)
      end
      it 'マイページリンクが表示される: 左上から1番目のリンクが「マイページ」である' do
        farmers_link = find_all('a')[2].native.inner_text
        expect(farmers_link).to match(/farmers/i)
      end
      it '求人一覧リンクが表示される: 左上から3番目のリンクが「求人一覧」である' do
        job_offers_link = find_all('a')[3].native.inner_text
        expect(job_offers_link).to match(/job_offers/i)
      end
      it 'log outリンクが表示される: 左上から4番目のリンクが「ログアウト」である' do
        logout_link = find_all('a')[4].native.inner_text
        expect(logout_link).to match(/logout/i)
      end
    end
  end

  describe '農業者ログアウトのテスト' do
    let(:farmer) { create(:farmer) }

    before do
      visit new_farmer_session_path
      fill_in 'farmer[email]', with: farmer.email
      fill_in 'farmer[password]', with: farmer.password
      click_button 'ログイン'
      logout_link = find_all('a')[4].native.inner_text
      logout_link = logout_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
      click_link logout_link
    end

    context 'ログアウト機能のテスト' do
      it '正しくログアウトできている: ログアウト後のリダイレクト先においてAbout画面へのリンクが存在する' do
        expect(page).to have_link '', href: '/about'
      end
      it 'ログアウト後のリダイレクト先が、トップになっている' do
        expect(current_path).to eq '/'
      end
    end
  end
end