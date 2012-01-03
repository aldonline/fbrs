prefixes = require '../prefixes'
rules = []

class InferenceRule
  constructor: ( opts ) ->
    o =
      # datalog syntax
      head: null
      body: null

###
INSERT INTO <LOBGraph>
{?client :hasProduct :product1}
WHERE {?client :isWithLOB :lob1} .
###

rules.push
  head:'?IN fbx:work_employer ?OUT'
  body:'?IN user:work [ api:has [ :employer ?OUT ] ]'

rules.push
  head:'?IN fbx:education_school ?OUT'
  body:'?IN user:education [ api:has [ :school ?OUT ] ]'








###
  work_location :
    label: 'Location'
    path: '?IN user:work [ api:has [ :location ?OUT ] ]'
  work_position :
    label: 'Position'
    path: '?IN user:work [ api:has [ :position ?OUT ] ]'
  work_coworker :
    label: 'Works With'
    path: '?IN user:work [ api:has [ :with [ api:has ?OUT ] ] ]'
  work_project :
    label: 'Works With'
    path: '?IN user:work [ api:has [ :projects [ api:has ?OUT ] ] ]'
###