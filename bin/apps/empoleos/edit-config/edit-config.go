package main

import (
	"bytes"
	"os"
	"reflect"
	"strings"

	"gopkg.in/yaml.v2"
)

func main(){
	args := os.Args
	if len(args) < 5 {
		return
	}

	configFile := args[1]
	pkgMan := args[2]
	pkgName := args[3]
	pkgVal := args[4]

	pkgRepo := ""
	if len(args) > 5 {
		pkgRepo = args[5]
	}

	conf, err := os.ReadFile(configFile)
	if err != nil {
		panic(err)
	}

	var config map[interface{}]interface{}
	yaml.Unmarshal(conf, &config)

	if (pkgMan == "flatpak" || pkgMan == "flatpak-repo") && pkgRepo != "" {
		if _, ok := config["flatpak"]; !ok {
			config["flatpak"] = map[interface{}]interface{}{}
		}

		if val, ok := config["flatpak"].(map[interface{}]interface{})["_types"]; ok && reflect.TypeOf(val) == reflect.TypeOf("") {
			valList := strings.Split(val.(string), " ")
			hasVal := -1
			for i, v := range valList {
				if v == pkgRepo {
					hasVal = i
					break
				}
			}
			if hasVal == -1 && (pkgVal == "yes" || pkgMan == "flatpak") {
				valList = append(valList, pkgRepo)
			}else if hasVal != -1 && pkgVal == "no" && pkgMan != "flatpak" {
				valList = append(valList[:hasVal], valList[hasVal+1:]...)
			}
			config["flatpak"].(map[interface{}]interface{})["_types"] = strings.Join(valList, " ")
		}else if pkgVal == "yes" || pkgMan == "flatpak" {
			config["flatpak"].(map[interface{}]interface{})["_types"] = pkgRepo
		}

		if _, ok := config["flatpak"].(map[interface{}]interface{})[pkgRepo]; !ok {
			config["flatpak"].(map[interface{}]interface{})[pkgRepo] = map[interface{}]interface{}{}
		}

		if pkgMan == "flatpak" {
			if pkgVal == "yes" {
				config["flatpak"].(map[interface{}]interface{})[pkgRepo].(map[interface{}]interface{})[pkgName] = true
			}else if pkgVal == "no" {
				config["flatpak"].(map[interface{}]interface{})[pkgRepo].(map[interface{}]interface{})[pkgName] = false
			}else{
				config["flatpak"].(map[interface{}]interface{})[pkgRepo].(map[interface{}]interface{})[pkgName] = pkgVal
			}
		}else if pkgMan == "flatpak-repo" {
			if pkgVal == "yes" {
				config["flatpak"].(map[interface{}]interface{})[pkgRepo].(map[interface{}]interface{})["_remote"] = pkgName
			}else if pkgVal == "no" {
				hasPkg := false
				for key, val := range config["flatpak"].(map[interface{}]interface{})[pkgRepo].(map[interface{}]interface{}) {
					if key != "_remote" && val == true {
						hasPkg = true
						break
					}
				}
				if !hasPkg {
					delete(config["flatpak"].(map[interface{}]interface{}), pkgRepo)
				}else if val, ok := config["flatpak"].(map[interface{}]interface{})["_types"]; ok && reflect.TypeOf(val) == reflect.TypeOf("") {
					valList := strings.Split(val.(string), " ")
					hasVal := -1
					for i, v := range valList {
						if v == pkgRepo {
							hasVal = i
							break
						}
					}
					if hasVal == -1 {
						valList = append(valList, pkgRepo)
						config["flatpak"].(map[interface{}]interface{})["_types"] = strings.Join(valList, " ")
					}
				}
			}
		}
	}else{
		if _, ok := config[pkgMan]; !ok {
			config[pkgMan] = map[interface{}]interface{}{}
		}

		if pkgVal == "yes" {
			config[pkgMan].(map[interface{}]interface{})[pkgName] = true
		}else if pkgVal == "no" {
			config[pkgMan].(map[interface{}]interface{})[pkgName] = false
		}else{
			config[pkgMan].(map[interface{}]interface{})[pkgName] = pkgVal
		}
	}

	config = trimConfigNil(config)

	res, err := yaml.Marshal(config)
	if err != nil {
		panic(err)
	}

	res = bytes.ReplaceAll(res, []byte(`: true`), []byte(`: yes`))
	res = bytes.ReplaceAll(res, []byte(`: false`), []byte(`: no`))
	res = bytes.ReplaceAll(res, []byte(`'`), []byte{})
	res = bytes.ReplaceAll(res, []byte(`"`), []byte{})
	res = bytes.ReplaceAll(res, []byte(`:  `), []byte(`: `))
	res = bytes.ReplaceAll(res, []byte(` \n`), []byte(`\n`))

	os.WriteFile(configFile, res, 0644)
}

func trimConfigNil(config map[interface{}]interface{}) map[interface{}]interface{} {
	for key, val := range config {
		if v, ok := val.(map[interface{}]interface{}); ok {
			v = trimConfigNil(v)
			if len(v) == 0 {
				delete(config, key)
			}else{
				config[key] = v
			}
		}else if val == nil {
			delete(config, key)
		}
	}
	return config
}
