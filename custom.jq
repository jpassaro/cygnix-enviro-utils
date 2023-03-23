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

def unflatten_jp_list_entries:
    map(
      if .key | length > 1
      then (.superkey = .key[0]) | (.subkey = .key[1:])
      else (.superkey = null) | (.subkey = (.key | if length > 0 then .[0] else null end))
      end
    ) | group_by(.superkey) | [
      .[]  # for each group
        | if .[0].superkey == null
           then .[] | {key: .subkey, value}
           else {
             key: .[0].superkey,
             value: map({key: .subkey, value}) | unflatten_jp_list_entries
           }
           end
    ] | from_entries
;

def unflatten_jp: to_entries | map(.key |= split(".")) | unflatten_jp_list_entries;


def generify($prefix):
  . as $orig |
  if type == "object"
  then with_entries(.key as $k | (.value |= generify([$prefix[], $k])))
  elif type == "array"
  then to_entries | map((.key | tostring) as $k | .value | generify([$prefix[], $k]))
  elif type == "string"
  then $prefix | join(".")
  else $orig
  end
;

def generify:
  generify([])
;

def to_ddb:
  if type == "null"
    then {"NULL": true}
  elif type == "string"
    then {"S": .}
  elif type == "number"
    then {"N": tostring}
  elif type == "boolean"
    then {"BOOL": .}
  elif type == "object"
    then {"M": map_values(to_ddb)}
  elif type == "array"
    then {"L": map(to_ddb)}
  else
    error("unknown type \(type)")
  end
;
