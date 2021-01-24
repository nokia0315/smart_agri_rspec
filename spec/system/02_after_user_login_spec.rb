require 'rails_helper'

describe '[STEP2] ユーザログイン後のテスト' do
  let(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:review) { create(:review, user: user) }
  let!(:other_review) { create(:review, user: other_user) }

  before do
    visit new_user_session_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'ログイン'
  end

  describe 'ヘッダーのテスト: ログインしている場合' do
    context 'リンクの内容を確認: ※logoutは『ユーザログアウトのテスト』でテスト済みになります。' do
      subject { current_path }

      it 'マイページを押すと、自分のユーザ詳細画面に遷移する' do
        user_link = find_all('a')[1].native.inner_text
        user_link = user_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link user_link
        is_expected.to eq '/job_offers/' + user.id.to_s
      end
      it '求人一覧を押すと、求人一覧画面に遷移する' do
        job_offers_link = find_all('a')[2].native.inner_text
        job_offers_link = job_offers_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link job_offers_link
        is_expected.to eq '/job_offers'
      end
    end
  end

  describe 'レビュー一覧画面のテスト' do
    before do
      visit users_farmer_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq 'users/farmers/:id'
      end

      it '自分の投稿と他人の投稿の星評価が表示される' do
        expect(page).to have_content review.rate
        expect(page).to have_content other_review.rate
      end
    end

    context 'レビュー投稿成功のテスト' do
      before do
        fill_in 'review[title]', with: Faker::Lorem.characters(number: 5)
        fill_in 'review[rete]', with: Faker::Lorem.characters(number: 20)
        fill_in 'review[explanation]', with: Faker::Lorem.characters(number: 20)
      end

      it '自分の新しい投稿が正しく保存される' do
        expect { click_button '投稿' }.to change(user.reviews, :count).by(1)
      end
      it 'リダイレクト先が、保存できた投稿の詳細画面になっている' do
        click_button '投稿'
        expect(current_path).to eq '/reviews/' + review.last.id.to_s
      end
    end
  end

  describe '自分のレビュー投稿詳細画面のテスト' do
    before do
      visit users_farmer_review_path(users_farmer_id: farmer.id, id: review.id)
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/reviews/' + review.id.to_s
      end
      it '「review detail」と表示される' do
        expect(page).to have_content 'review detail'
      end
      it '投稿のtitleが表示される' do
        expect(page).to have_content review.title
      end
      it '投稿のopinionが表示される' do
        expect(page).to have_content review.explanation
      end
      it '投稿の編集リンクが表示される' do
        expect(page).to have_link 'Edit', href: edit_users_farmer_review_path(@review)
      end
      it '投稿の削除リンクが表示される' do
        expect(page).to have_link 'Destroy', href: users_farmer_review_path(@review.farmer, @review)
      end
    end



    context '投稿成功のテスト' do
      before do
        fill_in 'review[title]', with: Faker::Lorem.characters(number: 5)
        fill_in 'review[rate]', with: Faker::Lorem.characters(number: 20)
        fill_in 'review[explanation]', with: Faker::Lorem.characters(number: 20)
      end

      it '自分の新しい投稿が正しく保存される' do
        expect { click_button '投稿' }.to change(user.reviews, :count).by(1)
      end
    end

    context '編集リンクのテスト' do
      it '編集画面に遷移する' do
        click_link 'Edit'
        expect(current_path).to eq '/reviews/' + review.id.to_s + '/edit'
      end
    end

    context '削除リンクのテスト' do
      before do
        click_link 'Destroy'
      end

      it '正しく削除される' do
        expect(review.where(id: review.id).count).to eq 0
      end
      it 'リダイレクト先が、投稿一覧画面になっている' do
        expect(current_path).to eq 'users/farmers/:id'
      end
    end
  end

  describe '自分の投稿編集画面のテスト' do
    before do
      visit edit_users_farmer_review_path(@review)
    end

    context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/reviews/' + review.id.to_s + '/edit'
      end
      it '「Editing review」と表示される' do
        expect(page).to have_content 'Editing review'
      end
      it 'title編集フォームが表示される' do
        expect(page).to have_field 'review[title]', with: review.title
      end
      it 'rate編集フォームが表示される' do
        expect(page).to have_field 'review[rate]', with: review.rate
      end
      it 'explanation編集フォームが表示される' do
        expect(page).to have_field 'review[explanation]', with: review.explanation
      end
      it 'Update reviewボタンが表示される' do
        expect(page).to have_button 'Update review'
      end
    end

    context '編集成功のテスト' do
      before do
        @review_old_title = review.title
        @review_old_rate = review.rate
        @review_old_explanation = review.explanation
        fill_in 'review[title]', with: Faker::Lorem.characters(number: 4)
        fill_in 'review[rate]', with: Faker::Lorem.characters(number: 4)
        fill_in 'review[explanation]', with: Faker::Lorem.characters(number: 19)
        click_button 'Update review'
      end

      it 'titleが正しく更新される' do
        expect(review.reload.title).not_to eq @review_old_title
      end
      it 'rateが正しく更新される' do
        expect(review.reload.rate).not_to eq @review_old_rate
      end
      it 'explanationが正しく更新される' do
        expect(review.reload.explanation).not_to eq @review_old_explanation
      end
      it 'リダイレクト先が、更新した投稿の詳細画面になっている' do
        expect(current_path).to eq '/reviews/' + review.id.to_s
        expect(page).to have_content 'review detail'
      end
    end
  end

  describe '求人一覧画面のテスト' do
    before do
      visit users_job_offers_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/job_offers/'
      end

      it '求人のshowリンクがそれぞれ表示される' do
        expect(page).to have_link 'Show', href: user_path(user)
        expect(page).to have_link 'Show', href: user_path(other_user)
      end
    end
  end

  describe '自分のユーザ詳細画面のテスト' do
    before do
      visit user_path(user)
    end

    context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/' + user.id.to_s
      end
    end
  end

  describe '自分のユーザ情報編集画面のテスト' do
    before do
      visit edit_user_path(@user)
    end

    context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/' + user.id.to_s + '/edit'
      end
      it '姓編集フォームに自分の名前が表示される' do
        expect(page).to have_field 'user[first_name]', with: user.first_name
      end
      it '名編集フォームに自分の名前が表示される' do
        expect(page).to have_field 'user[last_name]', with: user.last_name
      end
      it '姓カナ編集フォームに自分の名前が表示される' do
        expect(page).to have_field 'user[kana_first_name]', with: kana_first_name
      end
      it '名カナ編集フォームに自分の名前が表示される' do
        expect(page).to have_field 'user[kana_last_name]', with: kana_last_name
      end
      it '画像編集フォームが表示される' do
        expect(page).to have_field 'user[image]'
      end
      it '自己紹介編集フォームに自分の自己紹介文が表示される' do
        expect(page).to have_field 'user[introduction]', with: user.introduction
      end
      it 'Update Userボタンが表示される' do
        expect(page).to have_button 'Update User'
      end
    end

    context '更新成功のテスト' do
      before do
        @user_old_first_name = user.first_name
        @user_old_last_name = user.last_name
        @user_old_kana_first_name = user.kana_first_name
        @user_old_kana_last_name = user.kana_last_name
        @user_old_introduction = user.introduction
        fill_in 'user[first_name]', with: Faker::Lorem.characters(number: 9)
        fill_in 'user[last_name]', with: Faker::Lorem.characters(number: 9)
        fill_in 'user[kana_first_name]', with: Faker::Lorem.characters(number: 9)
        fill_in 'user[kana_last_name]', with: Faker::Lorem.characters(number: 9)
        fill_in 'user[introduction]', with: Faker::Lorem.characters(number: 19)
        click_button 'Update User'
      end

      it 'first_nameが正しく更新される' do
        expect(user.reload.name).not_to eq @user_old_first_name
      end
      it 'last_nameが正しく更新される' do
        expect(user.reload.name).not_to eq @user_old_last_name
      end
      it 'kana_first_nameが正しく更新される' do
        expect(user.reload.name).not_to eq @user_old_kana_first_name
      end
      it 'kana_last_nameが正しく更新される' do
        expect(user.reload.name).not_to eq @user_old_kana_last_name
      end
      it 'introductionが正しく更新される' do
        expect(user.reload.introduction).not_to eq @user_old_intrpduction
      end
      it 'リダイレクト先が、自分のユーザ詳細画面になっている' do
        expect(current_path).to eq '/users/' + user.id.to_s
      end
    end
  end
end