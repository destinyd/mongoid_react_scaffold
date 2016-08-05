module MongoidReactScaffoldHelper
  def save_model(model, wrap = nil, &block)
    if model.save
      data = block.call(model)
      data = {wrap.to_sym => data} if !wrap.blank?
      render json: data
    else
      data = model.errors.messages
      data = {wrap.to_sym => data} if !wrap.blank?
      render json: data, :status => 422
    end
  end

  def update_model(model, params_attrs, wrap = nil, &block)
    if model.update_attributes params_attrs
      data = block.call(model)
      data = {wrap.to_sym => data} if !wrap.blank?
      render json: data
    else
      data = model.errors.messages
      data = {wrap.to_sym => data} if !wrap.blank?
      render json: data, :status => 422
    end
  end
end
