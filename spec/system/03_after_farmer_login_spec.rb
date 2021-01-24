require 'rails_helper'

describe '[STEP2] 農業者ログイン後のテスト' do
  let(:farmer) { create(:farmer) }
  let!(:other_farmer) { create(:farmer) }
  let!(:job_offer) { create(:job_offer, farmer: farmer) }
  let!(:other_job_offer) { create(:job_offer, farmer: other_farmer) }

  before do
    visit new_farmer_session_path
    fill_in 'farmer[email]', with: farmer.email
    fill_in 'farmer[password]', with: farmer.password
    click_button 'ログイン'
  end

  describe 'ヘッダーのテスト: ログインしている場合' do
    context 'リンクの内容を確認: ※logoutは『農業者ログアウトのテスト』でテスト済みになります。' do
      subject { current_path }

      it 'マイページを押すと、自分の農業者詳細画面に遷移する' do
        farmer_link = find_all('a')[1].native.inner_text
        farmer_link = farmer_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link farmer_link
        is_expected.to eq '/job_offers/' + farmer.id.to_s
      end
      it '求人一覧を押すと、求人一覧画面に遷移する' do
        job_offers_link = find_all('a')[2].native.inner_text
        job_offers_link = job_offers_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link job_offers_link
        is_expected.to eq '/job_offers'
      end
    end
  end

  describe '求人一覧画面のテスト' do
    before do
      visit farmers_job_offers_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq 'farmers/job_offers/'
      end

      it '自分の投稿と他人の投稿が表示される' do
        expect(page).to have_content job_offer
        expect(page).to have_content other_job_offer
      end
    end

    context '求人投稿成功のテスト' do
      before do
        fill_in 'job_offer[title]', with: Faker::Lorem.characters(number: 5)
        fill_in 'job_offer[reward]', with: Faker::Lorem.characters(number: 20)
        fill_in 'job_offer[explanation]', with: Faker::Lorem.characters(number: 20)
      end

      it '自分の新しい投稿が正しく保存される' do
        expect { click_button '投稿' }.to change(farmer.job_offers, :count).by(1)
      end
      it 'リダイレクト先が、保存できた投稿の詳細画面になっている' do
        click_button '投稿'
        expect(current_path).to eq '/job_offers/' + job_offer.last.id.to_s
      end
    end
  end

  describe '自分の求人投稿詳細画面のテスト' do
    before do
      visit farmers_job_offer_path(@job_offer)
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/job_offers/' + job_offers.id.to_s
      end
      it '「job_offer detail」と表示される' do
        expect(page).to have_content 'job_offer detail'
      end
      it '投稿のtitleが表示される' do
        expect(page).to have_content job_offer.title
      end
      it '投稿のrewardが表示される' do
        expect(page).to have_content job_offer.reward
      end
      it '投稿のopinionが表示される' do
        expect(page).to have_content job_offer.explanation
      end
      it '投稿の編集リンクが表示される' do
        expect(page).to have_link 'Edit', href: edit_farmers_job_offer_path(@job_offer)
      end
      it '投稿の削除リンクが表示される' do
        expect(page).to have_link 'Destroy', href: farmers_job_offer_path(@job_offer)
      end
    end

    context '投稿成功のテスト' do
      before do
        fill_in 'job_offer[title]', with: Faker::Lorem.characters(number: 5)
        fill_in 'job_offer[reward]', with: Faker::Lorem.characters(number: 20)
        fill_in 'job_offer[explanation]', with: Faker::Lorem.characters(number: 20)
      end

      it '自分の新しい投稿が正しく保存される' do
        expect { click_button '投稿' }.to change(farmer.job_offers, :count).by(1)
      end
    end

    context '編集リンクのテスト' do
      it '編集画面に遷移する' do
        click_link 'Edit'
        expect(current_path).to eq '/job_offers/' + job_offer.id.to_s + '/edit'
      end
    end

    context '削除リンクのテスト' do
      before do
        click_link 'Destroy'
      end

      it '正しく削除される' do
        expect(job_offer.where(id: job_offer.id).count).to eq 0
      end
      it 'リダイレクト先が、投稿一覧画面になっている' do
        expect(current_path).to eq 'farmers/job_offers/'
      end
    end
  end

  describe '自分の投稿編集画面のテスト' do
    before do
      visit edit_farmers_job_offer_path(@job_offer)
    end

    context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/job_offers/' + job_offer.id.to_s + '/edit'
      end
      it '「Editing job_offer」と表示される' do
        expect(page).to have_content 'Editing job_offer'
      end
      it 'title編集フォームが表示される' do
        expect(page).to have_field 'job_offer[title]', with: job_offer.title
      end
      it 'reward編集フォームが表示される' do
        expect(page).to have_field 'job_offer[reward]', with: job_offer.reward
      end
      it 'explanation編集フォームが表示される' do
        expect(page).to have_field 'job_offer[explanation]', with: job_offer.explanation
      end
      it 'Update job_offerボタンが表示される' do
        expect(page).to have_button 'Update job_offer'
      end
    end

    context '編集成功のテスト' do
      before do
        @job_offer_old_title = job_offer.title
        @job_offer_old_reward = job_offer.reward
        @job_offer_old_explanation = job_offer.explanation
        fill_in 'job_offer[title]', with: Faker::Lorem.characters(number: 4)
        fill_in 'job_offer[reward]', with: Faker::Lorem.characters(number: 4)
        fill_in 'job_offer[explanation]', with: Faker::Lorem.characters(number: 19)
        click_button 'Update job_offer'
      end

      it 'titleが正しく更新される' do
        expect(job_offer.reload.title).not_to eq @job_offer_old_title
      end
      it 'rewardが正しく更新される' do
        expect(job_offer.reload.reward).not_to eq @job_offer_old_reward
      end
      it 'explanationが正しく更新される' do
        expect(job_offer.reload.explanation).not_to eq @job_offer_old_explanation
      end
      it 'リダイレクト先が、更新した投稿の詳細画面になっている' do
        expect(current_path).to eq '/job_offers/' + job_offer.id.to_s
        expect(page).to have_content 'job_offer detail'
      end
    end
  end

  describe '求人一覧画面のテスト' do
    before do
      visit farmers_job_offers_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/farmers/job_offers/'
      end

      it '求人のshowリンクがそれぞれ表示される' do
        expect(page).to have_link 'Show', href: job_offer_path(job_offer)
        expect(page).to have_link 'Show', href: job_offer_path(other_job_offer)
      end
    end
  end

  describe '自分の農業者詳細画面のテスト' do
    before do
      visit farmer_path(farmer)
    end

    context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/farmers/' + farmer.id.to_s
      end
    end
  end

  describe '自分の農業者情報編集画面のテスト' do
    before do
      visit edit_farmer_path(@farmer)
    end

    context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/farmers/' + farmer.id.to_s + '/edit'
      end
      it '姓編集フォームに自分の名前が表示される' do
        expect(page).to have_field 'farmer[first_name]', with: farmer.first_name
      end
      it '名編集フォームに自分の名前が表示される' do
        expect(page).to have_field 'farmer[last_name]', with: farmer.last_name
      end
      it '姓カナ編集フォームに自分の名前が表示される' do
        expect(page).to have_field 'farmer[kana_first_name]', with: kana_first_name
      end
      it '名カナ編集フォームに自分の名前が表示される' do
        expect(page).to have_field 'farmer[kana_last_name]', with: kana_last_name
      end
      it '画像編集フォームが表示される' do
        expect(page).to have_field 'farmer[image]'
      end
      it '自己紹介編集フォームに自分の自己紹介文が表示される' do
        expect(page).to have_field 'farmer[introduction]', with: farmer.introduction
      end
      it 'Update farmerボタンが表示される' do
        expect(page).to have_button 'Update farmer'
      end
    end

    context '更新成功のテスト' do
      before do
        @farmer_old_first_name = farmer.first_name
        @farmer_old_last_name = farmer.last_name
        @farmer_old_kana_first_name = farmer.kana_first_name
        @farmer_old_kana_last_name = farmer.kana_last_name
        @farmer_old_introduction = farmer.introduction
        fill_in 'farmer[first_name]', with: Faker::Lorem.characters(number: 9)
        fill_in 'farmer[last_name]', with: Faker::Lorem.characters(number: 9)
        fill_in 'farmer[kana_first_name]', with: Faker::Lorem.characters(number: 9)
        fill_in 'farmer[kana_last_name]', with: Faker::Lorem.characters(number: 9)
        fill_in 'farmer[introduction]', with: Faker::Lorem.characters(number: 19)
        click_button 'Update farmer'
      end

      it 'first_nameが正しく更新される' do
        expect(farmer.reload.name).not_to eq @farmer_old_first_name
      end
      it 'last_nameが正しく更新される' do
        expect(farmer.reload.name).not_to eq @farmer_old_last_name
      end
      it 'kana_first_nameが正しく更新される' do
        expect(farmer.reload.name).not_to eq @farmer_old_kana_first_name
      end
      it 'kana_last_nameが正しく更新される' do
        expect(farmer.reload.name).not_to eq @farmer_old_kana_last_name
      end
      it 'introductionが正しく更新される' do
        expect(farmer.reload.introduction).not_to eq @farmer_old_intrpduction
      end
      it 'リダイレクト先が、自分の農業者詳細画面になっている' do
        expect(current_path).to eq '/farmers/' + farmer.id.to_s
      end
    end
  end
end