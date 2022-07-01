

export const queryDB = async(apiQuery,cookies=false)=>{

    const requestOptions = {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(apiQuery),
        credentials: cookies?'include':'same-origin',
        
    };
    const res = await fetch('https://api.croco.digital/handler.php', requestOptions).then(response => response.json()).then(data=> {return data})
    
    return res

}

