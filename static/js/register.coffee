$(->
  $.get('/users', (data) ->
    for member in JSON.parse(data)
      $('#members tbody').append("""
        <tr>
          <td>#{member.number}</td>
          <td>#{member.name}</td>
          <td>#{moment(member.date, 'MMMM Do YYYY, h:mm:ss a').format('lll')}</td>
          <td><a href='https://tradeblock.com/bitcoin/tx/#{member.txid}' target='_blank'>#{member.txid.substr(0,10)}...</a></td>
        </tr>
      """)
  )
)
