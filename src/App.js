import './App.css';
import Header from './components/header';
import ProductCard from './components/productCard';
import SortBar from './components/sortBar';
import FilterBar from './components/FilterBar';
import { useState, useEffect } from "react";
import Context from './context';
import { queryDB } from './api/queryAPI';
import {Helmet} from "react-helmet";


function App() {

  
  const [cart, setCart] = useState([]);
  const [products, setproducts] = useState([])
  const [apiQuery, setapiQuery] = useState({ "action": "getproducts", "limit": 15, "offset": 0, "categoryid": -1, "orderby": 2 })
  const [refresh, setRefresh] = useState(false)

  useEffect(()=>{

    const cartQuery = {"action":"getcart"}
    
    queryDB(cartQuery,true).then(res=>res.queryresult==""?setCart([]):setCart(res.queryresult))
    
  },[refresh])

  useEffect(()=>{

    queryDB(apiQuery,true).then(res=>{setproducts(res.queryresult)})
      
  },[apiQuery])

  
  return (
    <Context.Provider value={[cart, setCart, refresh, setRefresh]}>
    <div className="App bg-gray-50">
    <Helmet>
              <script src="https://telegram.org/js/telegram-web-app.js" type="text/javascript" />
    </Helmet>
      <Header items = {cart} />
      <div className = "container mx-auto px-2 xl:mx-auto">

      <div className = "flex flex-col lg:flex-row lg:space-x-4 pb-4"> 
        <FilterBar Category ={setapiQuery}/>
        <div>
        <SortBar hits={products.length}/>
        <div className = "grid grid-cols-1 xl:grid-cols-4 gap-x-2 gap-y-2">

          {Array.from(products).map((el)=>
            <ProductCard details = {el} />
          )}

        </div>
        </div>
        </div>
      </div>
    </div>
    </Context.Provider>
  );
}

export default App;
