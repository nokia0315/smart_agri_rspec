require 'rails_helper'

RSpec.describe 'job_offerモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { job_offer.valid? }

    let(:farmer) { create(:farmer) }
    let!(:job_offer) { build(:job_offer, farmer_id: farmer.id) }

    context 'titleカラム' do
      it '空欄でないこと' do
        job_offer.title = ''
        is_expected.to eq false
      end
    end

    context 'rewardカラム' do
      it '空欄でないこと' do
        job_offer.reward = ''
        is_expected.to eq false
      end
       it '20文字以下であること: 20文字は〇' do
        job_offer.explanation = Faker::Lorem.characters(number: 1000)
        is_expected.to eq true
      end
      it '20文字以下であること: 20文字は×' do
        job_offer.explanation = Faker::Lorem.characters(number: 1001)
        is_expected.to eq false
      end
    end

    context 'explanationカラム' do
      it '空欄でないこと' do
        job_offer.explanation = ''
        is_expected.to eq false
      end

      it '1000文字以下であること: 1000文字は〇' do
        job_offer.explanation = Faker::Lorem.characters(number: 1000)
        is_expected.to eq true
      end
      it '1000文字以下であること: 1001文字は×' do
        job_offer.explanation = Faker::Lorem.characters(number: 1001)
        is_expected.to eq false
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'farmerモデルとの関係' do
      it 'N:1となっている' do
        expect(job_offer.reflect_on_association(:farmer).macro).to eq :belongs_to
      end
    end
  end
end