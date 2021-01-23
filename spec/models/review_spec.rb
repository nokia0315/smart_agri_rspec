require 'rails_helper'

RSpec.describe 'reviewモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { review.valid? }

    let(:user) { create(:user) }
    let!(:review) { build(:review, user_id: user.id) }

    context 'titleカラム' do
      it '空欄でないこと' do
        review.title = ''
        is_expected.to eq false
      end
    end

    context 'explanationカラム' do
      it '空欄でないこと' do
        review.explanation = ''
        is_expected.to eq false
      end
      
      it '1000文字以下であること: 1000文字は〇' do
        review.explanation = Faker::Lorem.characters(number: 1000)
        is_expected.to eq true
      end
      it '1000文字以下であること: 1001文字は×' do
        review.explanation = Faker::Lorem.characters(number: 1001)
        is_expected.to eq false
      end
    end
    
    context 'rateカラム' do
      it '空欄でないこと' do
        review.rate = ''
        is_expected.to eq false
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'userモデルとの関係' do
      it 'N:1となっている' do
        expect(review.reflect_on_association(:user).macro).to eq :belongs_to
      end
    end
  end
end