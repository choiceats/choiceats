// @flow
let accessToken = ''

export const getToken = () => accessToken
export const setToken = (token: string) => { accessToken = token }