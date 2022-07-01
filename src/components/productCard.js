import { useContext, useEffect, useState } from "react";
import Context from "../context";
import { queryDB } from "../api/queryAPI";
import { motion } from "framer-motion"


export default function ProductCard({details}){

    const [cart, ,refresh, setRefresh] = useContext(Context)
    const [inCart, setInCart] = useState(false)

    console.log("From Product:InCart", inCart)

    let isInCart = (el) =>el.productid === details.idproduct

    let checkCart = ()=>{

      if(Array.from(cart).some(isInCart)){
       
        return true

      }else{

        return false

      } 

      
    }

    useEffect(()=>{
      if(checkCart()){
        setInCart(true)
      }else{
        setInCart(false)
      }
    },[cart,refresh])

    useEffect(()=>{
      console.log("InCart",inCart)
      console.log("Refresh",refresh)
    },[inCart, refresh])

    let addToCart = (e)=>{

    e.preventDefault();

    const apiQuery = {"action":"addposition","productid":details.idproduct,"count":"1","userid":""}
		queryDB(apiQuery,true)
    .then(data => {if(data.status){
       console.log("added", data.status)
       setRefresh(!refresh)
      }else{
        console.log("not added", data.status)
      }}); 
    
    }

    return(
        <motion.div initial={{ opacity: 0 }}
        animate={{ opacity: 1 }} class="flex flex-col justify-between border h-full  border-blue-200 rounded-t-2xl">
  

  <img
    class="object-cover w-full h-72 lg:h-72 rounded-t-2xl"
    src={details.imageURI}
    alt="Build Your Own Drone"
    loading="lazy"
  />

  <div class="justify-self-end p-6">

    <div>
    <h5 class="mt-4 text-lg font-bold">
      {details.name}
    </h5>

    <p class="mt-2 text-sm text-gray-700">
      {details.cost}
    </p>
    </div>

<div class = "justify-self-end">
    {inCart ? <div id = {details.idproduct} class="block w-full p-4 mt-4 text-sm font-medium text-blue-500 bg-gray-100 rounded-sm" >Added to Cart</div> :<motion.button whileHover={{ scale: 1.2 }} whileTap={{ scale: 0.8 }} id = {details.idproduct} class="block w-full p-4 mt-4 text-sm font-medium text-gray-100 bg-blue-500 rounded-sm" type="button" onClick ={(e)=>addToCart(e)}>Add to Cart</motion.button>}
</div>
  </div>
</motion.div>
    )
}
