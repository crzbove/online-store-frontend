import { useState, useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import { queryDB } from '../api/queryAPI'
import {Helmet} from "react-helmet";

export default function CheckOut(){

  const [cart,setCart] = useState([])
  const [user, setUser] = useState()
  const [invoice, showInvoice] =useState(false)
  const [invoiceMessage, setInvoiceMessage] = useState("")

  let Navigate = useNavigate()

  useEffect(()=>{

    const cartQuery = {"action":"getcart"}
    
    queryDB(cartQuery,true).then(res=>res.queryresult==""?setCart([]):setCart(res.queryresult))
    
  },[user])

  useEffect(() => {
		
		const apiQuery = { "action": "getauth" }
		queryDB(apiQuery,true)
			.then(res => res.queryresult == "" ? setUser(null) : setUser(res.queryresult));
	}, [])

  let sendInvoice = (e)=>{

    e.preventDefault()
    const apiQuery = { "action": "sendinvoice" }
		queryDB(apiQuery,true)
			.then(res => res.status? invoiceSuccess() : invoiceFail());

  }

  let invoiceSuccess = ()=>{

    showInvoice(true);
    setInvoiceMessage("The invoice has been sent to your email. Redirecting you back to Storefront")
    const apiQuery = { "action": "getcartshort" }
		queryDB(apiQuery,true)
			.then(res => res.status? window.Telegram.WebApp.sendData(JSON.stringify(res.queryresult)) : console.log("failed to send to bot. Check queryres", res.queryresult))
      .then(()=>{
        queryDB({"action":"completecheckout"},true)
        setTimeout(()=>Navigate("/", { replace: true }), 3000)
      })
    

  }

  let invoiceFail = ()=>{

    showInvoice(true);
    setInvoiceMessage("An error has occured. Redirecting you back to Storefront")
    setTimeout(()=>Navigate("/", { replace: true }), 3000)

  }

  console.log(cart)
  console.log(user)

    return(
        <section className="min-h-screen">
          {invoice?<div className="flex flex-col justify-center items-center absolute z-10 w-full min-h-full bg-blue-400/80 bg-repeat-y">
          <div className="w-16 h-16 border-4 border-dashed rounded-full animate-spin border-white"></div>
          <div className ="text-2xl pt-2 font-medium text-gray-100">{invoiceMessage}</div>
          </div>:<></>}
          <Helmet>
              <script src="https://telegram.org/js/telegram-web-app.js" type="text/javascript" />
            </Helmet>
  <h1 class="sr-only">Checkout</h1>
{user != null ? 
  <div class="relative mx-auto max-w-screen-2xl min-h-screen">
    <div class="grid grid-cols-1 md:grid-cols-2">
      <div class="py-12 bg-gray-50 lg:min-h-screen md:py-24">
        <div class="max-w-lg px-4 mx-auto lg:px-8">
          <Link to="/"><div class="flex items-center">
            <span class="w-10 h-10 bg-blue-900 rounded-full"></span>

            <h2 class="ml-4 font-medium">Back To Store</h2>
          </div></Link>

          <div class="mt-8">
            <p class="text-2xl font-medium tracking-tight">{cart.length==0?"$0":cart[0].TOTALSUM}</p>
            <p class="mt-1 text-sm text-gray-500">For the purchase of</p>
          </div>

          <div class="mt-12">
            <div class="flow-root">
              <ul class="-my-4 divide-y divide-gray-200">

                {Array.from(cart).map((item)=><li class="flex items-center justify-between py-4">
                  <div class="flex items-start">
                    <img
                      class="flex-shrink-0 object-cover w-16 h-16 rounded-lg"
                      src={item.imageuri}
                      alt=""
                    />

                    <div class="ml-4">
                      <p class="text-sm">{item.name}</p>

                      
                    </div>
                  </div>

                  <div>
                    <p class="text-sm">
                      {item.cost}
                      <small class="text-gray-500">x{item.count}</small>
                    </p>
                  </div>
                </li>)}

                
              </ul>
            </div>
          </div>
        </div>
      </div>

      <div class="py-12 bg-white md:py-24">
        <div class="max-w-lg px-4 mx-auto lg:px-8">
          <div class="grid grid-cols-6 gap-4">
            <div class="col-span-6">
              <button
              class="rounded-lg bg-black text-sm p-2.5 text-white w-full block"
              onClick ={(e)=>sendInvoice(e)}>
                Buy Now
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>:<div className = "flex justify-center items-center text-3xl font-medium">You are not logged in. Click <Link to="/"> here</Link> to redirect back to store</div>}
</section>
    )
}