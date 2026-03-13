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

def flatten_jp_list:
  to_entries | map(
    .key as $herekey
    | .value
    | if type == "object" or type == "array"
      then flatten_jp_list[] | .keypart = [$herekey, .keypart[]]
      else {keypart: [$herekey], value: .}
      end
  )
;

def _flatten_unfull:
  map((.key = (.keypart | join("."))) | del(.keypart)) | from_entries
;

def flatten_jp_new:
  flatten_jp_list | _flatten_unfull
;

def flatten_jp_generic_keys_full:
  flatten_jp_list | map(
    .keypart |= map(if type == "number" then "##" else tostring end)
  ) | group_by(.keypart) | map({
    keypart: .[0].keypart,
    value: map(.value) | unique
  })
;

def flatten_jp_generic_full:
  flatten_jp_generic_keys_full | map(.value |= (
    map(type)|unique|join("|")
  ))
;

def flatten_jp_generic_keys:
  flatten_jp_generic_keys_full | _flatten_unfull
;

def flatten_jp_generic: flatten_jp_generic_full | _flatten_unfull
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

def _from_ddb:
  if type == "object"
    then
      if keys == ["NULL"] then null
      elif keys == ["S"] then .S
      elif keys == ["N"] then .N|tonumber
      elif keys == ["BOOL"] then .BOOL
      elif keys == ["L"] then .L|map(_from_ddb)
      elif keys == ["M"] then .M|map_values(_from_ddb)
      elif keys|length == 1
        then error(
          "unknown key \"\(keys[0])\", should be one of \"NULL\", \"BOOL\", \"N\", \"S\", \"L\", \"M\""
        )
      else error("object must have at most one key, one of \"NULL\", \"BOOL\", \"N\", \"S\", \"L\", \"M\"")
      end
  else error("unknown type \(type)")
  end
;

def from_ddb:
  map_values(_from_ddb)
;

def trynumber:
  . as $value | try tonumber catch $value
;

def recurse_sort_arrays:
  if type == "object" then map_values(recurse_sort_arrays)
  elif type == "array" then sort | map(recurse_sort_arrays)
  else .
  end
;
