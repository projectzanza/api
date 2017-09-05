require 'rails_helper'

RSpec.describe PositionsController, type: :controller do
  before(:each) do
    login_user
  end

  describe 'get#index' do
    it 'should return all positions for a user' do
      positions = (0...2).collect { create(:position, user: @user) }

      get :index,
          params: {
            user_id: @user.id
          }

      expect(data.length).to eq 2
      expect(data.first['title']).to eq positions.first[:title]
    end
  end

  describe 'post#create' do
    it 'should create a position associated with a user' do
      post :create,
           params: attributes_for(:position)

      expect(response).to have_http_status(:ok)
      expect(data['user_id']).to eq @user.id
    end

    it 'should only allow creating of positions for the current user' do
      user = create(:user)
      position = attributes_for(:position)

      post :create,
           params: position.merge(user_id: user.id)

      expect(user.positions.count).to eq 0
    end
  end

  describe 'put#update' do
    it 'should update the position attributes' do
      position = create(:position, user: @user)
      new_title = 'a new title'

      put :update,
          params: {
            id: position.id,
            title: 'a new title'
          }

      expect(response).to have_http_status(:ok)
      expect(data['title']).to eq new_title
    end
  end

  describe 'delete#destroy' do
    it 'should soft delete the position' do
      position = create(:position, user: @user)

      delete :destroy,
             params: {
               id: position.id
             }

      expect(response).to have_http_status(:ok)
      expect(json['success']).to eq true
      expect(position.reload.deleted_at).to be_truthy
    end
  end
end
