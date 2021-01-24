require 'rails_helper'

describe '[STEP3] 仕上げのテスト' do
  let(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:review) { create(:review, user: user) }
  let!(:other_review) { create(:review, user: other_user) }

  describe 'サクセスメッセージのテスト' do
    subject { page }

    it 'ユーザ新規登録成功時' do
      visit new_user_registration_path
      fill_in 'user[first_name]', with: Faker::Lorem.characters(number: 9)
      fill_in 'user[last_name]', with: Faker::Lorem.characters(number: 9)
      fill_in 'user[kana_first_name]', with: Faker::Lorem.characters(number: 9)
      fill_in 'user[kana_last_name]', with: Faker::Lorem.characters(number: 9)
      fill_in 'user[introduction]', with: Faker::Lorem.characters(number: 19)
      fill_in 'user[email]', with: 'a' + user.email # 確実にuser, other_userと違う文字列にするため
      fill_in 'user[password]', with: 'password'
      fill_in 'user[password_confirmation]', with: 'password'
      click_button 'Sign up'
      is_expected.to have_content 'successfully'
    end
    it 'ユーザログイン成功時' do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'Log in'
      is_expected.to have_content 'successfully'
    end
    it 'ユーザログアウト成功時' do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'Log in'
      logout_link = find_all('a')[4].native.inner_text
      logout_link = logout_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
      click_link logout_link
      is_expected.to have_content 'successfully'
    end
    it 'ユーザのプロフィール情報更新成功時' do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'Log in'
      visit edit_user_path(user)
      click_button 'Update User'
      is_expected.to have_content 'successfully'
    end
    it '投稿データの新規投稿成功時: 投稿一覧画面から行います。' do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'Log in'
      visit reviews_path
      fill_in 'review[title]', with: Faker::Lorem.characters(number: 5)
      fill_in 'review[rate]', with: Faker::Lorem.characters(number: 5)
      fill_in 'review[explanation]', with: Faker::Lorem.characters(number: 20)
      click_button 'Create review'
      is_expected.to have_content 'successfully'
    end
    it '投稿データの更新成功時' do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'Log in'
      visit edit_review_path(review)
      click_button 'Update review'
      is_expected.to have_content 'successfully'
    end
  end

  describe '処理失敗時のテスト' do
    context 'ユーザ新規登録失敗: emailを1文字にする' do
      before do
        visit new_user_registration_path
        @email = Faker::Lorem.characters(number: 1)
        @email = 'a' + user.email # 確実にuser, other_userと違う文字列にするため
        fill_in 'user[email]', with: @email
        fill_in 'user[email]', with: @email
        fill_in 'user[password]', with: 'password'
        fill_in 'user[password_confirmation]', with: 'password'
      end

      it '新規登録されない' do
        expect { click_button 'Sign up' }.not_to change(User.all, :count)
      end
      it '新規登録画面を表示しており、フォームの内容が正しい' do
        click_button 'Sign up'
        expect(page).to have_content 'Sign up'
        expect(page).to have_field 'user[email]', with: @email
        expect(page).to have_field 'user[email]', with: @email
      end
      it 'バリデーションエラーが表示される' do
        click_button 'Sign up'
        expect(page).to have_content "is too short (minimum is 2 characters)"
      end
    end

    context 'ユーザのプロフィール情報編集失敗: emailを1文字にする' do
      before do
        @user_old_email = user.email
        @email = Faker::Lorem.characters(number: 1)
        visit new_user_session_path
        fill_in 'user[email]', with: @user_old_email
        fill_in 'user[password]', with: user.password
        click_button 'Log in'
        visit edit_user_path(user)
        fill_in 'user[email]', with: @email
        click_button 'Update User'
      end

      it '更新されない' do
        expect(user.reload.email).to eq @user_old_email
      end
      it 'ユーザ編集画面を表示しており、フォームの内容が正しい' do
        expect(page).to have_field 'user[email]', with: @email
      end
      it 'バリデーションエラーが表示される' do
        expect(page).to have_content "is too short (minimum is 2 characters)"
      end
    end

    context '投稿データの新規投稿失敗: 投稿一覧画面から行い、titleを空にする' do
      before do
        visit new_user_session_path
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'Log in'
        visit reviews_path
        @explanation = Faker::Lorem.characters(number: 19)
        fill_in 'review[explanation]', with: @explanation
      end

      it '投稿が保存されない' do
        expect { click_button 'Create review' }.not_to change(review.all, :count)
      end
      it '投稿一覧画面を表示している' do
        click_button 'Create review'
        expect(current_path).to eq '/reviews'
        expect(page).to have_content review.explanation
        expect(page).to have_content other_review.explanation
      end
      it '新規投稿フォームの内容が正しい' do
        expect(find_field('review[title]').text).to be_blank
        expect(page).to have_field 'review[explanation]', with: @explanation
      end
      it 'バリデーションエラーが表示される' do
        click_button 'Create review'
        expect(page).to have_content "can't be blank"
      end
    end

    context '投稿データの更新失敗: titleを空にする' do
      before do
        visit new_user_session_path
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'Log in'
        visit edit_review_path(review)
        @review_old_title = review.title
        fill_in 'review[title]', with: ''
        click_button 'Update review'
      end

      it '投稿が更新されない' do
        expect(review.reload.title).to eq @review_old_title
      end
      it '投稿編集画面を表示しており、フォームの内容が正しい' do
        expect(current_path).to eq '/reviews/' + review.id.to_s
        expect(find_field('review[title]').text).to be_blank
        expect(page).to have_field 'review[explanation]', with: review.explanation
      end
      it 'エラーメッセージが表示される' do
        expect(page).to have_content 'error'
      end
    end
  end

  describe 'ログインしていない場合のアクセス制限のテスト: アクセスできず、ログイン画面に遷移する' do
    subject { current_path }

    it 'ユーザ一覧画面' do
      visit users_path
      is_expected.to eq '/users/sign_in'
    end
    it 'ユーザ詳細画面' do
      visit user_path(user)
      is_expected.to eq '/users/sign_in'
    end
    it 'ユーザ情報編集画面' do
      visit edit_user_path(user)
      is_expected.to eq '/users/sign_in'
    end
    it '投稿一覧画面' do
      visit reviews_path
      is_expected.to eq '/users/sign_in'
    end
    it '投稿詳細画面' do
      visit review_path(review)
      is_expected.to eq '/users/sign_in'
    end
    it '投稿編集画面' do
      visit edit_review_path(review)
      is_expected.to eq '/users/sign_in'
    end
  end

  describe '他人の画面のテスト' do
    before do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'Log in'
    end

    describe '他人の投稿詳細画面のテスト' do
      before do
        visit review_path(other_review)
      end

      context '表示内容の確認' do
        it 'URLが正しい' do
          expect(current_path).to eq '/reviews/' + other_review.id.to_s
        end
        it '「review detail」と表示される' do
          expect(page).to have_content 'review detail'
        end
        it 'ユーザ画像・名前のリンク先が正しい' do
          expect(page).to have_link other_review.user.email, href: user_path(other_review.user)
        end
        it '投稿のtitleが表示される' do
          expect(page).to have_content other_review.title
        end
        it '投稿のopinionが表示される' do
          expect(page).to have_content other_review.explanation
        end
        it '投稿の編集リンクが表示されない' do
          expect(page).not_to have_link 'Edit'
        end
        it '投稿の削除リンクが表示されない' do
          expect(page).not_to have_link 'Destroy'
        end
      end

      context 'サイドバーの確認' do
        it '他人の名前と紹介文が表示される' do
          expect(page).to have_content other_user.email
          expect(page).to have_content other_user.introduction
        end
        it '他人のユーザ編集画面へのリンクが存在する' do
          expect(page).to have_link '', href: edit_user_path(other_user)
        end
        it '自分の名前と紹介文は表示されない' do
          expect(page).not_to have_content user.email
          expect(page).not_to have_content user.introduction
        end
        it '自分のユーザ編集画面へのリンクは存在しない' do
          expect(page).not_to have_link '', href: edit_user_path(user)
        end
      end
    end

    context '他人の投稿編集画面' do
      it '遷移できず、投稿一覧画面にリダイレクトされる' do
        visit edit_review_path(other_review)
        expect(current_path).to eq '/reviews'
      end
    end

    describe '他人のユーザ詳細画面のテスト' do
      before do
        visit user_path(other_user)
      end

      context '表示の確認' do
        it 'URLが正しい' do
          expect(current_path).to eq '/users/' + other_user.id.to_s
        end
        it '投稿一覧のユーザ画像のリンク先が正しい' do
          expect(page).to have_link '', href: user_path(other_user)
        end
        it '投稿一覧に他人の投稿のtitleが表示され、リンクが正しい' do
          expect(page).to have_link other_review.title, href: review_path(other_review)
        end
        it '投稿一覧に他人の投稿のopinionが表示される' do
          expect(page).to have_content other_review.explanation
        end
        it '自分の投稿は表示されない' do
          expect(page).not_to have_content review.title
          expect(page).not_to have_content review.explanation
        end
      end

      context 'サイドバーの確認' do
        it '他人の名前と紹介文が表示される' do
          expect(page).to have_content other_user.email
          expect(page).to have_content other_user.introduction
        end
        it '他人のユーザ編集画面へのリンクが存在する' do
          expect(page).to have_link '', href: edit_user_path(other_user)
        end
        it '自分の名前と紹介文は表示されない' do
          expect(page).not_to have_content user.email
          expect(page).not_to have_content user.introduction
        end
        it '自分のユーザ編集画面へのリンクは存在しない' do
          expect(page).not_to have_link '', href: edit_user_path(user)
        end
      end
    end

    context '他人のユーザ情報編集画面' do
      it '遷移できず、自分のユーザ詳細画面にリダイレクトされる' do
        visit edit_user_path(other_user)
        expect(current_path).to eq '/users/' + user.id.to_s
      end
    end
  end

  describe 'グリッドシステムのテスト: container, row, col-xs-〇を正しく使えている' do
    subject { page }

    before do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'Log in'
    end

    it 'ユーザ一覧画面' do
      visit users_path
      is_expected.to have_selector '.container .row .col-md-3'
      is_expected.to have_selector '.container .row .col-md-8.offset-md-1'
    end
    it 'ユーザ詳細画面' do
      visit user_path(user)
      is_expected.to have_selector '.container .row .col-md-3'
      is_expected.to have_selector '.container .row .col-md-8.offset-md-1'
    end
    it '投稿一覧画面' do
      visit reviews_path
      is_expected.to have_selector '.container .row .col-md-3'
      is_expected.to have_selector '.container .row .col-md-8.offset-md-1'
    end
    it '投稿詳細画面' do
      visit review_path(review)
      is_expected.to have_selector '.container .row .col-md-3'
      is_expected.to have_selector '.container .row .col-md-8.offset-md-1'
    end
  end

  describe 'アイコンのテスト' do
    context 'トップ画面' do
      subject { page }

      before do
        visit root_path
      end

      it '本のアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-review'
      end
    end

    context 'アバウト画面' do
      subject { page }

      before do
        visit '/home/about'
      end

      it '本のアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-review'
      end
    end

    context 'ヘッダー: ログインしていない場合' do
      subject { page }

      before do
        visit root_path
      end

      it 'Homeリンクのアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-home'
      end
      it 'Aboutリンクのアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-link'
      end
      it 'sign upリンクのアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-user-plus'
      end
      it 'loginリンクのアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-sign-in-alt'
      end
    end

    context 'ヘッダー: ログインしている場合' do
      subject { page }

      before do
        visit new_user_session_path
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'Log in'
      end

      it 'Homeリンクのアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-home'
      end
      it 'Usersリンクのアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-users'
      end
      it 'reviewsリンクのアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-review-open'
      end
      it 'log outリンクのアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-sign-out-alt'
      end
    end

    context 'サイドバー' do
      subject { page }

      before do
        visit new_user_session_path
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'Log in'
      end

      it 'ユーザ一覧画面でレンチアイコンが表示される' do
        visit users_path
        is_expected.to have_selector '.fas.fa-user-cog'
      end
      it 'ユーザ詳細画面でレンチアイコンが表示される' do
        visit user_path(user)
        is_expected.to have_selector '.fas.fa-user-cog'
      end
      it '投稿一覧画面でレンチアイコンが表示される' do
        visit reviews_path
        is_expected.to have_selector '.fas.fa-user-cog'
      end
      it '投稿詳細画面でレンチアイコンが表示される' do
        visit review_path(review)
        is_expected.to have_selector '.fas.fa-user-cog'
      end
    end
  end
end