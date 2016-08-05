@PostsPage = React.createClass
  getInitialState: ->
    posts: @props.data.posts

  render: ->
    <div className='posts-page'>
    {
      if @state.posts.length is 0
        data =
          header: '设置'
          desc: '还没有创建任何数据'
          init_action: <PostsPage.CreateBtn data={@props.data} page={@} />
        <ManagerFuncNotReady data={data} />

      else
        <div>
          <PostsPage.CreateBtn data={@props.data} page={@} />
          <PostsPage.Table data={@state.posts} page={@} />
        </div>
    }
    </div>

  add_post: (post)->
    posts = Immutable.fromJS @state.posts
    posts = posts.push post
    @setState posts: posts.toJS()

  update_post: (post)->
    posts = Immutable.fromJS @state.posts
    posts = posts.map (x)->
      x = x.merge post if x.get('id') is post.id
      x
    @setState posts: posts.toJS()

  delete_post: (post)->
    posts = Immutable.fromJS @state.posts
    posts = posts.filter (x)->
      x.get('id') != post.id
    @setState posts: posts.toJS()

  statics:
    CreateBtn: React.createClass
      render: ->
        <a className='ui button green mini' href='javascript:;' onClick={@show_modal}>
          <i className='icon plus' />
          创建
        </a>

      show_modal: ->
        params =
          url: @props.data.create_url
          title: '创建'
          page: @props.page

        jQuery.open_modal <PostsPage.Form {...params} />

    Form: React.createClass
      render: ->
        {
          TextInputField
          Submit
        } = DataForm

        layout =
          label_width: '100px'

        <div>
          <h3 className='ui header'>{@props.title}</h3>
          <SimpleDataForm
            model='post'
            post={@props.url}
            done={@done}  
          >

            <TextInputField {...layout} label='name：' name='name' />
            <TextInputField {...layout} label='user_id：' name='user_id' />
            <Submit {...layout} text='确定保存' />
          </SimpleDataForm>
        </div>

      done: (data)->
        @props.page.add_post data.post
        @state.close()

    UpdateForm: React.createClass
      render: ->
        {
          TextInputField
          Submit
        } = DataForm

        layout =
          label_width: '100px'

        <div>
          <h3 className='ui header'>{@props.title}</h3>
          <SimpleDataForm
            model='post'
            put={@props.url}
            done={@done}
            data={@props.data}  
          >

            <TextInputField {...layout} label='name：' name='name' />
            <TextInputField {...layout} label='user_id：' name='user_id' />
            <Submit {...layout} text='确定保存' />
          </SimpleDataForm>
        </div>

      done: (data)->
        @props.page.update_post data.post
        @state.close()

    Table: React.createClass
      render: ->
        table_data = {
          fields:

            name: 'name'
            user_id: 'user_id'
            ops: '操作'
          data_set: @props.data.map (x)=>
            id: x.id

            name: x.name
            user_id: x.user_id
            ops:
              <div>
                <a href='javascript:;' className='ui basic button blue mini' onClick={@edit(x)}>
                  <i className='icon edit' /> 修改
                </a>
                <a href='javascript:;' className='ui basic button red mini' onClick={@delete(x)}>
                  <i className='icon trash' /> 删除
                </a>
              </div>

          th_classes: {
            number: 'collapsing'
          }
          td_classes: {
            ops: 'collapsing'
          }
        }

        <div className='ui segment'>
          <ManagerTable data={table_data} title='' />
        </div>

      edit: (post)->
        =>
          params =
            url: post.update_url
            title: '修改'
            page: @props.page
            data: post

          jQuery.open_modal <PostsPage.UpdateForm {...params} />

      delete: (post)->
        =>
          jQuery.modal_confirm
            text: '确定要删除吗？'
            yes: =>
              jQuery.ajax
                type: 'DELETE'
                url: post.delete_url
              .done =>
                @props.page.delete_post post
