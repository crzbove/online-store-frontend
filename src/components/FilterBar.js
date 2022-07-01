import { useEffect,useState } from "react";
import { motion } from "framer-motion"

export default function FilterBar({Category}) {


  const[categories, setCategories] = useState([])

  const container = {
    hidden: { opacity: 0 },
    show: {
      opacity: 1,
      transition: {
        staggerChildren: 0.5
      }
    }
  }
  
  const item = {
    hidden: { opacity: 0 },
    show: { opacity: 1 }
  }

  useEffect(()=>{
    const requestOptions = {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ "action": "getcategories" }),
      
  };
  fetch('https://api.croco.digital/handler.php', requestOptions)
      .then(response => response.json())
      .then(data => setCategories(data.queryresult));
  },[])

  let changeCategory = (e) =>{

    e.preventDefault()

    Category({ 
      "action": "getproducts", 
      "limit": 15, 
      "offset": 0, 
      "categoryid": parseInt(e.target.id), 
      "orderby": 2 })

  }


  return (
    <div class="lg:sticky lg:top-4 mt-4 w-full lg:max-w-max mx-auto lg:mx-0">
      <details
        open
        class="overflow-hidden border border-gray-200 rounded"
      >
        <summary class="flex items-center justify-between px-5 py-3 bg-blue-100 lg:hidden">
          <span class="text-sm font-medium">
            Change Category
          </span>

          <svg class="w-5 h-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </summary>

        <form
          action=""
          class="border-t border-gray-200 lg:border-t-0"
        >
          <fieldset>
            <legend class="block w-full px-5 py-3 text-xs font-medium bg-blue-50">
              Category
            </legend>

            <motion.div variants={container} initial="hidden" animate="show" class="px-5 py-6 space-y-2">
              <div class="flex items-center">

                <motion.button whileHover={{ scale: 1.2 }}
  whileTap={{ scale: 0.8 }}
                  id="-1"
                  class="ml-2 text-left text-sm font-medium hover:text-blue-400"
                  onClick ={(e)=>changeCategory(e)}>
                All
                </motion.button>
              </div>

              {categories.map((el)=><motion.div variants={item} class="flex items-center">
                

                <motion.button whileHover={{ scale: 1.2 }}
  whileTap={{ scale: 0.8 }}
                  id={el.idcategory}
                  class="ml-2 text-left text-sm font-medium hover:text-blue-400"
                onClick ={(e)=>changeCategory(e)}>
                  {el.categoryname}
                </motion.button>
              </motion.div>)}

            </motion.div>
          </fieldset>



          <div class="hidden flex-col space-y-2 px-5 py-3 border-t border-gray-200">
            <button
              name="reset"
              type="button"
              class="text-xs font-medium text-gray-600 underline rounded"
            >
              Reset All
            </button>

            <button
              name="commit"
              type="button"
              class="px-5 py-3 text-xs font-medium text-white bg-green-600 rounded"
            >
              Apply Filters
            </button>
          </div>
        </form>
      </details>
    </div>
  )
}