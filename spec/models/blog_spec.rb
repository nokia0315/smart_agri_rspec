require 'rails_helper'

RSpec.describe 'blogモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { blog.valid? }

    let(:farmer) { create(:farmer) }
    let!(:blog) { build(:blog, farmer_id: farmer.id) }

    context 'titleカラム' do
      it '空欄でないこと' do
        blog.title = ''
        is_expected.to eq false
      end
    end

    context 'explanationカラム' do
      it '空欄でないこと' do
        blog.explanation = ''
        is_expected.to eq false
      end
      it '空欄でないこと' do
        blog.reward = ''
        is_expected.to eq false
      end
      it '3000文字以下であること: 3000文字は〇' do
        blog.explanation = Faker::Lorem.characters(number: 3000)
        is_expected.to eq true
      end
      it '3000文字以下であること: 3001文字は×' do
        blog.explanation = Faker::Lorem.characters(number: 3001)
        is_expected.to eq false
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'farmerモデルとの関係' do
      it 'N:1となっている' do
        expect(blog.reflect_on_association(:farmer).macro).to eq :belongs_to
      end
    end
  end
end