import { useState, useContext, useEffect } from 'react'
import Context from "../context";
import { Link } from "react-router-dom";
import { queryDB } from '../api/queryAPI';
import { motion } from "framer-motion"

export default function Header({ items}) {

	const [cartOpen, setCartOpen] = useState(false)
	const [, setCart,refresh, setRefresh] = useContext(Context)
	const [loggedIn, setLoggedIn] = useState(false)
	const [signInSuccess, setSignInSuccess] = useState(false)
	const [authStatus, setAuthStatus]= useState(false)
	const [signInVis, setSignInVis] = useState(false)
	const [signUpVis, setSignUpVis] = useState(false)
	const [email, setEmail] = useState("")
	const [validEmail, setValidEmail]=useState(true)
	const [password, setPassword] = useState("")
	const [rpassword, setrPassword] = useState("")
	const [passMatch, setPassMatch] = useState(true)

	const [maxh, setMaxh] = useState("100vh")

	useEffect(()=>{
		if(typeof window != "undefined"){

			setMaxh(window.innerHeight)
		}
	},[])

	const item = {
		hidden: { opacity: 0, y:-100 },
		show: { opacity: 1, y:0 }
	}

	const item2 = {
		hidden: { opacity: 0 },
		show: { opacity: 1 }
	  }

	const container = {
		hidden: { opacity: 0 },
		show: {
		  opacity: 1,
		  transition: {
			staggerChildren: 0.5
		  }
		}
	  }

	let increaseQty = (id, count) => {

		const apiQuery = { "action": "updateposition", "productid": id, "count": parseInt(count) + 1 }
		queryDB(apiQuery,true)
		.then(data => { console.log("Increase", data); setRefresh(!refresh) });

	}

	let decreaseQty = (id, count) => {

		const apiQuery = { "action": "updateposition", "productid": id, "count": parseInt(count) - 1 }
		queryDB(apiQuery,true)
		.then(data => { console.log("Decrease", data); setRefresh(!refresh) });

	}

	let delCartItem = (id) => {

		const apiQuery = { "action": "deleteposition", "productid": id, }
		queryDB(apiQuery,true)
		.then(data => { console.log("Delete", data); setRefresh(!refresh) });
	}

	let openSignIn = (e) => {

		e.preventDefault()
		setSignInVis(!signInVis)

	}

	let openSignUp = (e) => {

		e.preventDefault()
		setSignUpVis(!signUpVis)

	}

	let signIn = (e) => {

		e.preventDefault()

		const apiQuery = {"action":"getauth","email":email,"password":password}
		queryDB(apiQuery,true)
		.then(res=>{res.status == false ? setSignInSuccess(false): setSignInSuccess(true);setSignInVis(false)})

	}

	let signUp = (e) => {

		e.preventDefault()

		if(password.length == 0 || validEmail==false){
			return
		}

		const apiQuery = {"action":"createuser","email":email,"password":password}
		queryDB(apiQuery,true)
		.then(res=>{res.status == false? setSignInSuccess(false): setSignInSuccess(true);setSignUpVis(false)})

	}

	let passwordMatch = (e) =>{
		setrPassword(e.target.value)
		if(e.target.value == password){
			setPassMatch(true)
		}else{
			setPassMatch(false)
		}
	}

	let logout = (e)=>{

		e.preventDefault()

		const apiQuery = {"action":"logout"}
		queryDB(apiQuery,true)
		.then(res=>{res.status == false ? setLoggedIn(true): setLoggedIn(false);})

	}

	let emailValid = (mail)=>{
		
	var mailformat = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
	if(mail.match(mailformat)){
		//alert("Valid email address!");
		//document.form1.text1.focus();
		setValidEmail(true);
	}else{
		//alert("You have entered an invalid email address!");
		//document.form1.text1.focus();
		setValidEmail(false);
}
	}

	useEffect(() => {
		
		const apiQuery = { "action": "getauth" }
		queryDB(apiQuery,true)
			.then(res => res.status == false ? setLoggedIn(false) : setLoggedIn(true));
	}, [signInSuccess])

	return (
		<header className="p-4 dark:bg-gray-800 dark:text-gray-100">
			{cartOpen ? <div className="flex flex-col flex-auto justify-start items-center absolute overflow-y-auto -m-4 z-10 w-full min-h-[200vh] bg-gray-400/80 bg-repeat-y">
				<motion.div initial={cartOpen?"hidden":"show"} animate={cartOpen?"show":"hidden"} variants={item} className="flex flex-col relative overflow-y-auto max-h-max z-10 my-2 max-w-3xl p-6 space-y-4 sm:p-10 bg-gray-100 dark:text-gray-100">
					<h2 className="text-xl font-semibold">Your cart</h2>
					<motion.ul variants={container} initial="hidden" animate="show" className="flex flex-col divide-y divide-gray-700">

						{items.length === 0 ? <div>Cart Is Empty</div> : Array.from(items).map((item) => <motion.li variants={item2} key={item.idproduct} className="flex flex-col py-6 sm:flex-row sm:justify-between">
							<div className="flex w-full space-x-2 sm:space-x-4">
								<img className="flex-shrink-0 object-cover w-20 h-20 dark:border-transparent rounded outline-none sm:w-32 sm:h-32 dark:bg-gray-500" src={item.imageuri} alt="Polaroid camera" />
								<div className="flex flex-col justify-between w-full pb-4">
									<div className="flex justify-between w-full pb-2 space-x-2">
										<div className="space-y-1">
											<h3 className="text-lg font-semibold leading-snug sm:pr-8">{item.name}</h3>

										</div>
										<div className="text-right">
											<p className="text-lg font-semibold">{item.total}</p>
											<p className="text-sm line-through dark:text-gray-600 hidden">75.50€</p>
										</div>
									</div>

									<div className="flex flex-col text-sm space-y-2 mt-1">
										<div class="custom-number-input h-10 w-32">
											<div class="flex flex-row h-10 w-full rounded-lg relative bg-transparent mt-1">
												<button data-action="decrement" class=" bg-gray-300 text-gray-600 hover:text-gray-700 hover:bg-gray-400 h-full w-20 rounded-l cursor-pointer outline-none" onClick={() => decreaseQty(item.productid, item.count)}>
													<span class="m-auto text-2xl font-thin" >-</span>
												</button>
												<input type="number" class=" focus:outline-none text-center w-full bg-gray-300 font-semibold text-md hover:text-black focus:text-black  md:text-basecursor-default flex items-center text-gray-700 apperance-none outline-none" name="custom-input-number" min="1" value={item.count} />
												<button data-action="increment" class="bg-gray-300 text-gray-600 hover:text-gray-700 hover:bg-gray-400 h-full w-20 rounded-r cursor-pointer" onClick={() => increaseQty(item.productid, item.count)}>
													<span class="m-auto text-2xl font-thin">+</span>
												</button>
											</div>
										</div>
										<motion.button whileTap={{ scale: 0.8 }} id={item.productid} type="button" className="flex items-center px-2 py-1 pl-0 space-x-1" onClick={() => delCartItem(item.productid)}>
											<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" className="w-4 h-4 fill-current">
												<path d="M96,472a23.82,23.82,0,0,0,23.579,24H392.421A23.82,23.82,0,0,0,416,472V152H96Zm32-288H384V464H128Z"></path>
												<rect width="32" height="200" x="168" y="216"></rect>
												<rect width="32" height="200" x="240" y="216"></rect>
												<rect width="32" height="200" x="312" y="216"></rect>
												<path d="M328,88V40c0-13.458-9.488-24-21.6-24H205.6C193.488,16,184,26.542,184,40V88H64v32H448V88ZM216,48h80V88H216Z"></path>
											</svg>
											<span className="cursor-pointer" >Remove</span>
										</motion.button>

									</div>
								</div>
							</div>
						</motion.li>)}


					</motion.ul>
					<div className="space-y-1 text-right">
						<p>Total amount:
							<span className="font-semibold">{items.length==0?"$0":items[0].TOTALSUM}</span>
						</p>
						<p className="text-sm dark:text-gray-400">Not including taxes and shipping costs</p>
					</div>
					<div className="flex justify-end space-x-4">
						<motion.button whileHover={{ scale: 1.2 }} whileTap={{ scale: 0.8 }} type="button" className="px-6 py-2 border rounded-md dark:border-violet-400" onClick={() => setCartOpen(false)}>Back
							<span className="sr-only sm:not-sr-only"> to shop</span>
						</motion.button>
						{items.length!=0 ? <Link to="/checkout"><motion.button whileHover={{ scale: 1.2 }} whileTap={{ scale: 0.8 }} type="button" className="px-6 py-2 border rounded-md dark:bg-violet-400 dark:text-gray-900 dark:border-violet-400" >
							<span className="sr-only sm:not-sr-only">Continue to</span> Checkout
						</motion.button></Link> : <></>}
					</div>
				</motion.div>
			</div> : <></>}
			{signInVis ? <div className="flex justify-center items-center fixed -m-4 z-10 w-full min-h-screen bg-gray-400/80">
				
				<motion.div initial={signInVis?"hidden":"show"} animate={signInVis?"show":"hidden"} variants={item} className="flex flex-col max-w-md p-6 rounded-md sm:p-10 bg-gray-100 text-gray-800">
					<div className="flex justify-end text-gray-800 cursor-pointer" onClick={openSignIn}>✖</div>
					<div className="mb-8 text-center">
						<h1 className="my-3 text-4xl font-bold">Sign in</h1>
						<p className="text-sm text-gray-800">Sign in to access your account</p>
					</div>
					<form novalidate="" action="" className="space-y-12 ng-untouched ng-pristine ng-valid">
						<div className="space-y-4">
							<div>
								<label for="email" className="block mb-2 text-sm text-left">Email Address</label>
								<input type="email" name="email" id="email" placeholder="leroy@jenkins.com" className="w-full px-3 py-2 border rounded-md border-blue-400 bg-gray-50 text-gray-800" onChange={(e) => setEmail(e.target.value)} />
							</div>
							<div>
								<div className="flex justify-between mb-2">
									<label for="password" className="text-sm">Password</label>
									<a rel="noopener noreferrer" href="#" className="text-xs hover:underline text-gray-800">Forgot password?</a>
								</div>
								<input type="password" name="password" id="password" placeholder="*****" className="w-full px-3 py-2 border rounded-md border-blue-400 bg-gray-50 text-gray-800" onChange={(e) => setPassword(e.target.value)} />
							</div>
						</div>
						<div className="space-y-2">
							<div>
								<button type="button" className="w-full px-8 py-3 font-semibold rounded-md bg-blue-400 text-gray-900" onClick={(e) => signIn(e)}>Sign in</button>
							</div>
							<p className="px-6 text-sm text-center text-gray-800">Don't have an account yet?
								<a rel="noopener noreferrer" href="#" className="hover:underline text-blue-400">Sign up</a>.
							</p>
						</div>
					</form>
				</motion.div>
				
			</div> : <></>}
			{signUpVis ? <div className="flex justify-center items-center fixed -m-4 z-10 w-full min-h-screen bg-gray-400/80">
				
				<motion.div initial={signUpVis?"hidden":"show"} animate={signUpVis?"show":"hidden"} variants={item} className="flex flex-col max-w-md p-6 rounded-md sm:p-10 bg-gray-100 text-gray-800">
					<div className="flex justify-end text-gray-800 cursor-pointer" onClick={openSignUp}>✖</div>
					<div className="mb-8 text-center">
						<h1 className="my-3 text-4xl font-bold">Sign Up</h1>
						<p className="text-sm text-gray-800">Sign up and start shopping</p>
					</div>
					<form novalidate="" action="" className="space-y-12 ng-untouched ng-pristine ng-valid">
						<div className="space-y-4">
							<div>
								<label for="email" className="block mb-2 text-sm text-left">Email Address</label>
								<input type="email" name="email" id="email" placeholder="leroy@jenkins.com" className="w-full px-3 py-2 border rounded-md border-blue-400 bg-gray-50 text-gray-800" onChange={(e) => {setEmail(e.target.value);emailValid(e.target.value)}} />
							</div>
							<div>
								<div className="flex justify-between mb-2">
									<label for="password" className="text-sm">Password</label>									
								</div>
								<input type="password" name="password" id="password" placeholder="*****" className="w-full px-3 py-2 border rounded-md border-blue-400 bg-gray-50 text-gray-800" onChange={(e) => setPassword(e.target.value)} />

								<div className="flex justify-between mb-2 mt-4">
									<label for="password" className="text-sm">Repeat Password</label>						
								</div>
								<input type="password" name="password" id="rpassword" placeholder="*****" className="w-full px-3 py-2 border rounded-md border-blue-400 bg-gray-50 text-gray-800" onChange={(e) => passwordMatch(e)} />
							</div>
						</div>
						<div className="space-y-2">
							<div>
								{rpassword.length!=0 ? passMatch?<div>Passwords Match</div>:<div>Passwords Don't  Match</div>:<></>}
								{validEmail ? <></>:<div>Email Not Valid</div>}
								<button type="button" className="w-full px-8 py-3 font-semibold rounded-md bg-blue-400 text-gray-900" onClick={(e) => signUp(e)}>Sign Up</button>
							</div>
							
						</div>
					</form>
				</motion.div>
				
			</div> : <></>}
			<div className="container flex justify-between h-16 mx-auto ">
				<a rel="noopener noreferrer" href="google.com" aria-label="Back to homepage" className="flex items-center p-2">
					<svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 32 32" className="w-8 h-8 dark:text-blue-400">
						<path d="M27.912 7.289l-10.324-5.961c-0.455-0.268-1.002-0.425-1.588-0.425s-1.133 0.158-1.604 0.433l0.015-0.008-10.324 5.961c-0.955 0.561-1.586 1.582-1.588 2.75v11.922c0.002 1.168 0.635 2.189 1.574 2.742l0.016 0.008 10.322 5.961c0.455 0.267 1.004 0.425 1.59 0.425 0.584 0 1.131-0.158 1.602-0.433l-0.014 0.008 10.322-5.961c0.955-0.561 1.586-1.582 1.588-2.75v-11.922c-0.002-1.168-0.633-2.189-1.573-2.742zM27.383 21.961c0 0.389-0.211 0.73-0.526 0.914l-0.004 0.002-10.324 5.961c-0.152 0.088-0.334 0.142-0.53 0.142s-0.377-0.053-0.535-0.145l0.005 0.002-10.324-5.961c-0.319-0.186-0.529-0.527-0.529-0.916v-11.922c0-0.389 0.211-0.73 0.526-0.914l0.004-0.002 10.324-5.961c0.152-0.090 0.334-0.143 0.53-0.143s0.377 0.053 0.535 0.144l-0.006-0.002 10.324 5.961c0.319 0.185 0.529 0.527 0.529 0.916z"></path>
						<path d="M22.094 19.451h-0.758c-0.188 0-0.363 0.049-0.515 0.135l0.006-0.004-4.574 2.512-5.282-3.049v-6.082l5.282-3.051 4.576 2.504c0.146 0.082 0.323 0.131 0.508 0.131h0.758c0.293 0 0.529-0.239 0.529-0.531v-0.716c0-0.2-0.11-0.373-0.271-0.463l-0.004-0.002-5.078-2.777c-0.293-0.164-0.645-0.26-1.015-0.26-0.39 0-0.756 0.106-1.070 0.289l0.010-0.006-5.281 3.049c-0.636 0.375-1.056 1.055-1.059 1.834v6.082c0 0.779 0.422 1.461 1.049 1.828l0.009 0.006 5.281 3.049c0.305 0.178 0.67 0.284 1.061 0.284 0.373 0 0.723-0.098 1.027-0.265l-0.012 0.006 5.080-2.787c0.166-0.091 0.276-0.265 0.276-0.465v-0.716c0-0.293-0.238-0.529-0.529-0.529z"></path>
					</svg>
				</a>

				<div className="items-center flex-shrink-0 flex space-x-2">
					{loggedIn ? 
					<>
					<motion.button whileHover={{ scale: 1.2 }} whileTap={{ scale: 0.8 }} className="self-center px-8 py-3 font-semibold rounded bg-blue-400 text-gray-100" onClick={(e)=>logout(e)}>Log Out</motion.button>
					<div className="relative" onClick={() => { setCartOpen(true) }}><div className="absolute inline-block top-0 right-0 bg-blue-400 rounded-full text-white font-bold hover:cursor-pointer px-2 py-1 align-top -mr-2 -mt-2 text-xs" >{items.length}</div><img className="h-10 w-10 inline-block mx-auto" src="https://www.freeiconspng.com/thumbs/cart-icon/basket-cart-icon-27.png" alt="cart icon" /></div></> 
					:
					<>
					<motion.button whileHover={{ scale: 1.2 }} whileTap={{ scale: 0.8 }} className="self-center px-8 py-3 rounded" onClick={openSignIn}>Sign in</motion.button>
					<motion.button whileHover={{ scale: 1.2 }} whileTap={{ scale: 0.8 }} className="self-center px-8 py-3 font-semibold rounded bg-blue-400 text-gray-100" onClick={openSignUp}>Sign up</motion.button>
					</>}
				</div>

			</div>
		</header>
	)
}