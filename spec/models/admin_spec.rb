require 'rails_helper'

RSpec.describe 'adminモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { admin.valid? }

    let!(:other_admin) { create(:admin) }
    let(:admin) { build(:admin) }

    context 'first_name, last_name, kana_first_name, kana_last_nameカラム' do
      it '空欄でないこと' do
        admin.first_name = ''
        is_expected.to eq false
      end

      it '空欄でないこと' do
        admin.last_name = ''
        is_expected.to eq false
      end

      it '20文字以下であること: 20文字は〇' do
        admin.first_name = Faker::Lorem.characters(number: 20)
        is_expected.to eq true
      end

      it '20文字以下であること: 20文字は〇' do
        admin.last_name = Faker::Lorem.characters(number: 20)
        is_expected.to eq true
      end
      
      it '20文字以下であること: 21文字は×' do
        admin.first_name = Faker::Lorem.characters(number: 21)
        is_expected.to eq false
      end
      it '一意性があること' do
        admin.email = other_admin.email
        is_expected.to eq false
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'genreモデルとの関係' do
      it '1:Nとなっている' do
        expect(admin.reflect_on_association(:genres).macro).to eq :has_many
      end
    end
  end
end