require 'rails_helper'

describe '[STEP2] 管理者ログイン後のテスト' do
  let(:admin) { create(:admin) }
  let!(:other_admin) { create(:admin) }
  let!(:genre) { create(:genre, admin: admin) }
  let!(:other_genre) { create(:genre, admin: other_admin) }

  before do
    visit new_admin_session_path
    fill_in 'admin[email]', with: admin.email
    fill_in 'admin[password]', with: admin.password
    click_button 'ログイン'
  end

  describe 'ヘッダーのテスト: ログインしている場合' do
    context 'リンクの内容を確認: ※logoutは『管理者ログアウトのテスト』でテスト済みになります。' do
      subject { current_path }

      it 'マイページを押すと、自分の管理者詳細画面に遷移する' do
        admin_link = find_all('a')[1].native.inner_text
        admin_link = admin_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link admin_link
        is_expected.to eq '/genres/' + admin.id.to_s
      end
      it '求人一覧を押すと、求人一覧画面に遷移する' do
        genres_link = find_all('a')[2].native.inner_text
        genres_link = genres_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link genres_link
        is_expected.to eq '/genres'
      end
    end
  end

  describe '求人一覧画面のテスト' do
    before do
      visit admins_genres_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq 'admins/genres/'
      end

      it '自分の投稿と他人の投稿が表示される' do
        expect(page).to have_content genre
        expect(page).to have_content other_genre
      end
    end

    context '求人投稿成功のテスト' do
      before do
        fill_in 'genre[title]', with: Faker::Lorem.characters(number: 5)
        fill_in 'genre[reward]', with: Faker::Lorem.characters(number: 20)
        fill_in 'genre[explanation]', with: Faker::Lorem.characters(number: 20)
      end

      it '自分の新しい投稿が正しく保存される' do
        expect { click_button '投稿' }.to change(admin.genres, :count).by(1)
      end
      it 'リダイレクト先が、保存できた投稿の詳細画面になっている' do
        click_button '投稿'
        expect(current_path).to eq '/genres/' + genre.last.id.to_s
      end
    end
  end

  describe '自分の求人投稿詳細画面のテスト' do
    before do
      visit admins_genre_path(@genre)
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/genres/' + genres.id.to_s
      end
      it '「genre detail」と表示される' do
        expect(page).to have_content 'genre detail'
      end
      it '投稿のtitleが表示される' do
        expect(page).to have_content genre.title
      end
      it '投稿のrewardが表示される' do
        expect(page).to have_content genre.reward
      end
      it '投稿のopinionが表示される' do
        expect(page).to have_content genre.explanation
      end
      it '投稿の編集リンクが表示される' do
        expect(page).to have_link 'Edit', href: edit_admins_genre_path(@genre)
      end
      it '投稿の削除リンクが表示される' do
        expect(page).to have_link 'Destroy', href: admins_genre_path(@genre)
      end
    end

    context '投稿成功のテスト' do
      before do
        fill_in 'genre[title]', with: Faker::Lorem.characters(number: 5)
        fill_in 'genre[reward]', with: Faker::Lorem.characters(number: 20)
        fill_in 'genre[explanation]', with: Faker::Lorem.characters(number: 20)
      end

      it '自分の新しい投稿が正しく保存される' do
        expect { click_button '投稿' }.to change(admin.genres, :count).by(1)
      end
    end

    context '編集リンクのテスト' do
      it '編集画面に遷移する' do
        click_link 'Edit'
        expect(current_path).to eq '/genres/' + genre.id.to_s + '/edit'
      end
    end

    context '削除リンクのテスト' do
      before do
        click_link 'Destroy'
      end

      it '正しく削除される' do
        expect(genre.where(id: genre.id).count).to eq 0
      end
      it 'リダイレクト先が、投稿一覧画面になっている' do
        expect(current_path).to eq 'admins/genres/'
      end
    end
  end

  describe '自分の投稿編集画面のテスト' do
    before do
      visit edit_admins_genre_path(@genre)
    end

    context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/genres/' + genre.id.to_s + '/edit'
      end
      it '「Editing genre」と表示される' do
        expect(page).to have_content 'Editing genre'
      end
      it 'title編集フォームが表示される' do
        expect(page).to have_field 'genre[title]', with: genre.title
      end
      it 'reward編集フォームが表示される' do
        expect(page).to have_field 'genre[reward]', with: genre.reward
      end
      it 'explanation編集フォームが表示される' do
        expect(page).to have_field 'genre[explanation]', with: genre.explanation
      end
      it 'Update genreボタンが表示される' do
        expect(page).to have_button 'Update genre'
      end
    end

    context '編集成功のテスト' do
      before do
        @genre_old_title = genre.title
        @genre_old_reward = genre.reward
        @genre_old_explanation = genre.explanation
        fill_in 'genre[title]', with: Faker::Lorem.characters(number: 4)
        fill_in 'genre[reward]', with: Faker::Lorem.characters(number: 4)
        fill_in 'genre[explanation]', with: Faker::Lorem.characters(number: 19)
        click_button 'Update genre'
      end

      it 'titleが正しく更新される' do
        expect(genre.reload.title).not_to eq @genre_old_title
      end
      it 'rewardが正しく更新される' do
        expect(genre.reload.reward).not_to eq @genre_old_reward
      end
      it 'explanationが正しく更新される' do
        expect(genre.reload.explanation).not_to eq @genre_old_explanation
      end
      it 'リダイレクト先が、更新した投稿の詳細画面になっている' do
        expect(current_path).to eq '/genres/' + genre.id.to_s
        expect(page).to have_content 'genre detail'
      end
    end
  end

  describe '求人一覧画面のテスト' do
    before do
      visit admins_genres_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/admins/genres/'
      end

      it '求人のshowリンクがそれぞれ表示される' do
        expect(page).to have_link 'Show', href: genre_path(genre)
        expect(page).to have_link 'Show', href: genre_path(other_genre)
      end
    end
  end

  describe '自分の管理者詳細画面のテスト' do
    before do
      visit admin_path(admin)
    end

    context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/admins/' + admin.id.to_s
      end
    end
  end

  describe '自分の管理者情報編集画面のテスト' do
    before do
      visit edit_admin_path(@admin)
    end

    context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/admins/' + admin.id.to_s + '/edit'
      end
      it '姓編集フォームに自分の名前が表示される' do
        expect(page).to have_field 'admin[first_name]', with: admin.first_name
      end
      it '名編集フォームに自分の名前が表示される' do
        expect(page).to have_field 'admin[last_name]', with: admin.last_name
      end
      it '姓カナ編集フォームに自分の名前が表示される' do
        expect(page).to have_field 'admin[kana_first_name]', with: kana_first_name
      end
      it '名カナ編集フォームに自分の名前が表示される' do
        expect(page).to have_field 'admin[kana_last_name]', with: kana_last_name
      end
      it '画像編集フォームが表示される' do
        expect(page).to have_field 'admin[image]'
      end
      it '自己紹介編集フォームに自分の自己紹介文が表示される' do
        expect(page).to have_field 'admin[introduction]', with: admin.introduction
      end
      it 'Update adminボタンが表示される' do
        expect(page).to have_button 'Update admin'
      end
    end

    context '更新成功のテスト' do
      before do
        @admin_old_first_name = admin.first_name
        @admin_old_last_name = admin.last_name
        @admin_old_kana_first_name = admin.kana_first_name
        @admin_old_kana_last_name = admin.kana_last_name
        @admin_old_introduction = admin.introduction
        fill_in 'admin[first_name]', with: Faker::Lorem.characters(number: 9)
        fill_in 'admin[last_name]', with: Faker::Lorem.characters(number: 9)
        fill_in 'admin[kana_first_name]', with: Faker::Lorem.characters(number: 9)
        fill_in 'admin[kana_last_name]', with: Faker::Lorem.characters(number: 9)
        fill_in 'admin[introduction]', with: Faker::Lorem.characters(number: 19)
        click_button 'Update admin'
      end

      it 'first_nameが正しく更新される' do
        expect(admin.reload.name).not_to eq @admin_old_first_name
      end
      it 'last_nameが正しく更新される' do
        expect(admin.reload.name).not_to eq @admin_old_last_name
      end
      it 'kana_first_nameが正しく更新される' do
        expect(admin.reload.name).not_to eq @admin_old_kana_first_name
      end
      it 'kana_last_nameが正しく更新される' do
        expect(admin.reload.name).not_to eq @admin_old_kana_last_name
      end
      it 'introductionが正しく更新される' do
        expect(admin.reload.introduction).not_to eq @admin_old_intrpduction
      end
      it 'リダイレクト先が、自分の管理者詳細画面になっている' do
        expect(current_path).to eq '/admins/' + admin.id.to_s
      end
    end
  end
end