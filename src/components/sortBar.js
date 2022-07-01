export default function SortBar({hits}){


    return(
        <div className = "flex justify-between my-4 mx-2 lg:mx-0">

            <div className = "text-gray-500 text-sm">{hits} Products</div>
            <div class="ml-4">
            <label
              for="SortBy"
              class="sr-only"
            >
              Sort
            </label>

            <select
              id="SortBy"
              name="sort_by"
              className=" hidden text-sm border-2 border-gray-100 rounded"
            >
              <option readonly>Sort</option>
              <option value="title-asc">Title, A-Z</option>
              <option value="title-desc">Title, Z-A</option>
              <option value="price-asc">Price, Low-High</option>
              <option value="price-desc">Price, High-Low</option>
            </select>
          </div>
        

        </div>
    )
}