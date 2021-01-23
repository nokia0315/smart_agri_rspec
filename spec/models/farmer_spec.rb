require 'rails_helper'

RSpec.describe 'farmerモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { farmer.valid? }

    let!(:other_farmer) { create(:farmer) }
    let(:farmer) { build(:farmer) }

    context 'first_name, last_name, kana_first_name, kana_last_nameカラム' do
      it '空欄でないこと' do
        farmer.first_name = ''
        is_expected.to eq false
      end

      it '空欄でないこと' do
        farmer.last_name = ''
        is_expected.to eq false
      end

      it '20文字以下であること: 20文字は〇' do
        farmer.first_name = Faker::Lorem.characters(number: 20)
        is_expected.to eq true
      end

      it '20文字以下であること: 20文字は〇' do
        farmer.last_name = Faker::Lorem.characters(number: 20)
        is_expected.to eq true
      end
      it '20文字以下であること: 21文字は×' do
        farmer.first_name = Faker::Lorem.characters(number: 21)
        is_expected.to eq false
      end
      it '一意性があること' do
        farmer.email = other_farmer.email
        is_expected.to eq false
      end
    end

    context 'introductionカラム' do
      it '500文字以下であること: 500文字は〇' do
        farmer.introduction = Faker::Lorem.characters(number: 500)
        is_expected.to eq true
      end
      it '500文字以下であること: 501文字は×' do
        farmer.introduction = Faker::Lorem.characters(number: 501)
        is_expected.to eq false
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'job_offerモデルとの関係' do
      it '1:Nとなっている' do
        expect(farmer.reflect_on_association(:job_offers).macro).to eq :has_many
      end
    end
      context 'Blogモデルとの関係' do
      it '1:Nとなっている' do
        expect(farmer.reflect_on_association(:blogs).macro).to eq :has_many
      end
    end
  end
end