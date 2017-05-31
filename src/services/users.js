/* global fetch */
// @flow
export const getToken = () => {
  return window.localStorage.getItem('accessToken')
}

export const setToken = (token: string) => {
  return window.localStorage.setItem('accessToken', token)
}

export const login = (email: string, password: string) => {
  return fetch('http://localhost:4000/auth', {
    method: 'post',
    headers: {
      'content-type': 'application/json'
    },
    body: JSON.stringify({
      email,
      password
    })
  })
  .then(response => {
    if (response.status === 401) {
      throw Error('Bad password!')
    }

    return response.json()
  })
  .then(responseJson => {
    setToken(responseJson.token)
    window.location.reload()
  })
}

export const clearToken = () => {
  window.localStorage.removeItem('accessToken')
}
