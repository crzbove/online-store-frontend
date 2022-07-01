import { createContext } from "react";

const Context = createContext({
    cart:[],
    setCart: ()=>{},
    refresh: false,
    setRefresh:()=>{}
})

export default Context