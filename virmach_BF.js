const like = 9
const new_plan = 'https://billing.virmach.com/modules/addons/blackfriday/new_plan.json'
const add = 'https://billing.virmach.com/cart.php?a=add&pid=175&billingcycle=annually'

Notification.requestPermission()

let pre = ''

const main = async () => {
  let a = await fetch(new_plan)
  a = await a.json()
  cur = JSON.stringify(a)
  console.log(cur)
  if (pre === cur) {
    return
  }
  pre = cur
  a = parseFloat(a.price.match(/([\d\.]+)/)[1])
  if (a < like) {
    new Notification(a)
    window.open(add)
  }
}

main()
setInterval(main, 10000)
