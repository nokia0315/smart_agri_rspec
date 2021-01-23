require 'rails_helper'

RSpec.describe 'Userモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { user.valid? }

    let!(:other_user) { create(:user) }
    let(:user) { build(:user) }

    context 'first_name, last_name, kana_first_name, kana_last_name, emailカラム' do
      it '空欄でないこと' do
        user.first_name = ''
        is_expected.to eq false
      end

      it '空欄でないこと' do
        user.last_name = ''
        is_expected.to eq false
      end

      it '20文字以下であること: 20文字は〇' do
        user.first_name = Faker::Lorem.characters(number: 20)
        is_expected.to eq true
      end

      it '20文字以下であること: 20文字は〇' do
        user.last_name = Faker::Lorem.characters(number: 20)
        is_expected.to eq true
      end

      it '20文字以下であること: 21文字は×' do
        user.first_name = Faker::Lorem.characters(number: 21)
        is_expected.to eq false
      end

      it '20文字以下であること: 21文字は×' do
        user.last_name = Faker::Lorem.characters(number: 21)
        is_expected.to eq false
      end

      it '一意性があること' do
        user.email = other_user.email
        is_expected.to eq false
      end
    end

    context 'introductionカラム' do
      it '500文字以下であること: 500文字は〇' do
        user.introduction = Faker::Lorem.characters(number: 500)
        is_expected.to eq true
      end
      it '500文字以下であること: 501文字は×' do
        user.introduction = Faker::Lorem.characters(number: 501)
        is_expected.to eq false
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'Reviewモデルとの関係' do
      it '1:Nとなっている' do
        expect(User.reflect_on_association(:reviews).macro).to eq :has_many
      end
    end
      context 'Blogモデルとの関係' do
      it '1:Nとなっている' do
        expect(User.reflect_on_association(:blogs).macro).to eq :has_many
      end
    end
  end
end