document.addEventListener('DOMContentLoaded', function() {
  document.querySelector('#following').addEventListener('click', () => following());
  load_post();
})

function following() {
  document.querySelector('.loadpost').innerHTML = '';
  document.querySelector('.loadpost').style.display = 'block';
  document.querySelector('.profile').style.display = 'none';
  document.querySelector('.loadpost-profile').style.display = 'none';

  fetch('following')
  .then(response => response.json())
  .then(posts => {
    console.log(posts)
    for (var i = 0; i < posts.length; i++) {
      post = posts[i];
      append_post(post)
    }
  })
}

function clear_cache() {
  document.querySelector('.submitpost').style.display = 'block';
  document.querySelector('.loadpost').innerHTML = '';
  document.querySelector('.loadpost').style.display = 'block';
  document.querySelector('.profile').style.display = 'none';
  document.querySelector('.loadpost-profile').style.display = 'none';
}

function clear_cache_profile() {
  document.querySelector('.submitpost').style.display = 'none';
  document.querySelector('.loadpost').style.display = 'none';
  document.querySelector('.profile').style.display = 'block';
  document.querySelector('.profile').style.display = '';
  document.querySelector('.loadpost-profile').style.display = 'block';
  document.querySelector('.loadpost-profile').innerHTML = '';
}

function clear_cache_following() {
  document.querySelector('.submitpost').style.display = 'none';
  document.querySelector('.loadpost').innerHTML = '';
  document.querySelector('.loadpost').style.display = 'none';
  document.querySelector('.profile').style.display = 'none';
  document.querySelector('.loadpost-profile').style.display = 'none';
  document.querySelector('.loadpost-following').style.display = 'block';
}

function load_post_following(pagenumber) {
  clear_cache_following()

  if ((pagenumber === undefined) || (pagenumber < 1)) {
    pagenumber = 1;
  }

  fetch('following-post?page='+pagenumber)
  .then(response => response.json())
  .then(result => {
    console.log(result)

    if ((result.page.num_page >= 2) && (pagenumber === 1)) {
      clear_cache()
      var next = document.querySelector('#next')
      next.className = "page-item"
      next.addEventListener('click', () => load_post(pagenumber+1))
      var previous = document.querySelector('#previous')
      previous.className = "page-item disabled"
    }
    else if ((result.page.num_page >= 2) && (pagenumber < result.page.num_page)) {
      clear_cache()
      var next = document.querySelector('#next')
      next.className = "page-item"
      next.addEventListener('click', () => load_post(pagenumber+1))
      var previous = document.querySelector('#previous')
      previous.className = "page-item"
      previous.addEventListener('click', () => load_post(pagenumber-1))
    }
    else if (result.page.num_page < 2) {
      clear_cache()
      var next = document.querySelector('#next')
      next.className = "page-item disabled"
      var previous = document.querySelector('#previous')
      previous.className = "page-item disabled"
    }
    else {
      clear_cache()
      var next = document.querySelector('#next')
      next.className = "page-item disabled"
      var previous = document.querySelector('#previous')
      previous.className = "page-item"
      previous.addEventListener('click', () => load_post(pagenumber-1))
    }

    for (var i = 0; i < result.posts.length; i++) {
      post = result.posts[i];
      append_post(post, result.requestid)
    }

  })
}

function load_post(pagenumber) {
    clear_cache()

    if ((pagenumber === undefined) || (pagenumber < 1)) {
      pagenumber = 1;
    }

    fetch('load?page='+pagenumber)
    .then(response => response.json())
    .then(result => {
      console.log(result)

      if ((result.page.num_page >= 2) && (pagenumber === 1)) {
        clear_cache()
        var next = document.querySelector('#next')
        next.className = "page-item"
        next.addEventListener('click', () => load_post(pagenumber+1))
        var previous = document.querySelector('#previous')
        previous.className = "page-item disabled"
      }
      else if ((result.page.num_page >= 2) && (pagenumber < result.page.num_page)) {
        clear_cache()
        var next = document.querySelector('#next')
        next.className = "page-item"
        next.addEventListener('click', () => load_post(pagenumber+1))
        var previous = document.querySelector('#previous')
        previous.className = "page-item"
        previous.addEventListener('click', () => load_post(pagenumber-1))
      }
      else if (result.page.num_page < 2) {
        clear_cache()
        var next = document.querySelector('#next')
        next.className = "page-item disabled"
        var previous = document.querySelector('#previous')
        previous.className = "page-item disabled"
      }
      else {
        clear_cache()
        var next = document.querySelector('#next')
        next.className = "page-item disabled"
        var previous = document.querySelector('#previous')
        previous.className = "page-item"
        previous.addEventListener('click', () => load_post(pagenumber-1))
      }

      for (var i = 0; i < result.posts.length; i++) {
        post = result.posts[i];
        append_post(post, result.requestid)
      }

    })
}

function load_profile_post(id, pagenumber) {
  clear_cache_profile()

  if ((pagenumber === undefined) || (pagenumber < 1)) {
    pagenumber = 1;
  }

  fetch('load-post/' + id + '?page=' + pagenumber)
  .then(response => response.json())
  .then(result => {
    
    console.log(result)

    if ((result.page.num_page >= 2) && (pagenumber === 1)) {
      clear_cache_profile()
      var next = document.querySelector('#next')
      next.className = "page-item"
      next.addEventListener('click', () => load_profile_post(id,pagenumber+1))
      var previous = document.querySelector('#previous')
      previous.className = "page-item disabled"
    }
    else if ((result.page.num_page >= 2) && (pagenumber < result.page.num_page)) {
      clear_cache_profile()
      var next = document.querySelector('#next')
      next.className = "page-item"
      next.addEventListener('click', () => load_profile_post(id,pagenumber+1))
      var previous = document.querySelector('#previous')
      previous.className = "page-item"
      previous.addEventListener('click', () => load_profile_post(id,pagenumber-1))
    }
    else if (result.page.num_page < 2) {
      clear_cache_profile()
      var next = document.querySelector('#next')
      next.className = "page-item disabled"
      var previous = document.querySelector('#previous')
      previous.className = "page-item disabled"
    }
    else {
      clear_cache_profile()
      var next = document.querySelector('#next')
      next.className = "page-item disabled"
      var previous = document.querySelector('#previous')
      previous.className = "page-item"
      previous.addEventListener('click', () => load_profile_post(id,pagenumber-1))
    }

    for (var i = 0; i < result.posts.length; i++) {
      post = result.posts[i];
      append_post(post,result.requestid)
    }
  })
}

function load_profile(id) {

  var profile = document.querySelector('.profile');
  profile.innerHTML = ``;
  var post = document.querySelector('.loadpost-profile');
  post.innerHTML = ``; 


  document.querySelector('.loadpost').style.display = 'none';
  document.querySelector('.profile').style.display = 'block';
  document.querySelector('.loadpost-profile').style.display = 'block';

  fetch('profile/' + id)
  .then(response => response.json())
  .then(profile => {
    console.log(profile)

    var maincontainer = document.querySelector('.profile')

    var div_item = document.createElement('div')
    div_item.className = "card text-center"
    var div_header = document.createElement('div')
    div_header.className = "card-header"
    div_header.innerHTML = 
    `
    Profile page
    `
    div_item.appendChild(div_header)

    var div_body = document.createElement('div')
    div_body.className = "card-body"
    div_body.innerHTML = 
    `
    <h5 class="card-title">${profile.username}</h5>
    <p class="card-text">Following: ${profile.following}</p>
    <p class="card-text">Follower: ${profile.follower}</p>
    `
    var div_follow_button = document.createElement('a')
    div_follow_button.className = "btn btn-primary"
    div_follow_button.id = "follow_button"
    div_follow_button.addEventListener('click', () => follow(profile.profile_user_id))
    if (profile.followed == false && profile.can_follow == true) {
      div_follow_button.innerHTML = `Follow`
      div_body.appendChild(div_follow_button);
    } 
    else if (profile.followed == true && profile.can_follow == true) {
      div_follow_button.innerHTML = `Unfollow`
      div_body.appendChild(div_follow_button);
    }


    div_item.appendChild(div_body)
    maincontainer.appendChild(div_item)

    load_profile_post(id,1);
  }
  )
}

function follow(id) {
  fetch('follow/' + id)
  .then(response => response.json())
  .then(result => {
    if (result.error) {
      console.log(result)
    }
    else {
      localStorage.clear();
    }
  }).then(function() {

    load_profile(id)
  });
  return false;
}


function append_post(post,id) {

  if (document.querySelector('.loadpost').style.display == 'block') {
    var maincontainer  = document.querySelector('.loadpost')
  }
  else {
    var maincontainer  = document.querySelector('.loadpost-profile')
  }
  
  var div_item = document.createElement('div');
  div_item.className = "card";
  var div_header = document.createElement('h5')
  div_header.className = "card-header"
  var div_profile = document.createElement('p')
  div_profile.addEventListener('click', () => load_profile(post.userid))
  div_profile.innerHTML = `${post.user}`
  div_profile.style.display = 'inline'
  div_header.appendChild(div_profile)
  if (id == post.userid) {
    var button_item = document.createElement('button')
    button_item.className = "btn btn-info"
    button_item.innerHTML = "Edit post"
    button_item.style.display = 'inline'
    button_item.style.marginLeft = '10px'
    div_header.appendChild(button_item)
    button_item.addEventListener('click', () => {
      var textarea = document.createElement('textarea')
      textid = 'text-' + String(post.id)
      saveid = 'save-' + String(post.id)
      textarea.id = textid
      textarea.cols = 60
      textarea.rows = 5
      postid = '#post-'+ String(post.id)
      bodyid = '#body-'+ String(post.id)
      
      textarea.innerHTML = document.querySelector(postid).innerHTML
      document.querySelector(postid).style.display = 'none'
      
      div_body = document.querySelector(bodyid)
      div_body.appendChild(textarea)

      var save = document.createElement('button')
      save.id = saveid
      save.innerHTML = 'Save'
      save.style.display = 'block'
      save.className = 'btn btn-success'

      save.addEventListener('click', () => {
        console.log(document.querySelector('#text-' + String(post.id)).value)
        fetch('/edit-post/' + post.id, {
          method: 'PUT',
          body: JSON.stringify({
              content: document.querySelector('#text-' + String(post.id)).value
          })
        });
        document.querySelector(postid).style.display = 'block'
        document.querySelector(postid).innerHTML = document.querySelector('#text-' + String(post.id)).value
        document.querySelector('#text-' + String(post.id)).innerHTML = ''
        document.querySelector('#text-' + String(post.id)).style.display = 'none'
        document.querySelector('#save-' + String(post.id)).style.display = 'none'
      })
      div_body.appendChild(save)
    })
  }
  div_item.appendChild(div_header)

  var div_body = document.createElement('div')
  div_body.className = "card-body"
  div_body.id = "body-"+String(post.id)
  div_body.innerHTML = 
  `
    <h5 class="card-title">Post at: ${post.timestamp}</h5>
    <p class="card-text" id="post-${post.id}">${post.post}</p>
  `
  div_item.appendChild(div_body)

  var div_footer = document.createElement('div')
  div_footer.className = "card-footer text-muted"
  div_footer.style.marginBottom = '10'
  div_footer.innerHTML =
  `
  <p id="like-${post.id}" style="display:inline margin-right:2">Likes: ${post.like_num}</p>
  ` 
  var div_like_button = document.createElement('a')
  div_like_button.className = "btn btn-warning"
  div_like_button.style.display = 'inline'
  div_like_button.id = "likebutton-" + String(post.id)
  div_like_button.addEventListener('click', () => {
    fetch('/like/' + post.id)
    .then(response => response.json())
    .then(result => {
      postid = "#like-" + String(post.id)
      buttonid = "#likebutton-" + String(post.id)
      document.querySelector(postid).innerHTML = `Likes: ${result.like_num}`
      document.querySelector(buttonid).innerHTML = `${result.button}`
    });
  })
  if (post.liked == false) {
    div_like_button.innerHTML = `Like`
    div_footer.appendChild(div_like_button);
  } 
  else {
    div_like_button.innerHTML = `Unlike`
    div_footer.appendChild(div_like_button);
  }
  div_item.appendChild(div_footer)
  
  maincontainer.appendChild(div_item);
} 