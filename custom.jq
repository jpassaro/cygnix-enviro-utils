def abs:
  if type == "number"
  then
    if . >= 0
    then .
    else -.
    end
  else error("abs requires a number, got \(type)")
  end
;


def dec_places:
  if type == "number"
  then
    if ([(. - floor),  (. - (-. | -floor))] | map(abs) | min) < 0.00000001
    then 0
    else 1 + ((10 * .) | dec_places)
    end
  else error("dec_places input must be a number, got \(type)")
  end
;


def from_entries_multi:
    reduce .[] as $item (
        {} ;
        . + {
            ($item.key): (
                (
                     (.[($item.key)])//[]
                ) + [($item.value)]
            )
        }
    )
;

def recurse_type:
  if type == "object"
  then map_values(recurse_type)
  elif type == "array"
  then map(recurse_type) | unique
  else type
  end
;

def flatten_jp:
  with_entries(
    (.key |= tostring)
    | . as $orig
    | .key as $upperkey
    | .value
    | if  type == "object" or type == "array"
      then flatten_jp | to_entries[] | .key |= "\($upperkey).\(.)"
      else $orig
      end
  )
;
