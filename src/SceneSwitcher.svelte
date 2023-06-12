<script>
  import { onMount } from 'svelte';
  import { obs, sendCommand } from './obs.js';
  import SourceButton from './SourceButton.svelte';
  import PlayerButton from './PlayerButton.svelte';

  export let programScene = {};
  export let previewScene = {};
  export let scenes = [];
  export let buttonStyle = 'text'; // text, screenshot, icon
  export let editable = false;

  const mapCameraSceneName = 'SRC Camera 4 Map';
  const mapCameraSceneItemName = 'Map Camera';
  let mapCameraSceneItemId;
  let isMapCameraEnabled;

  const sittingDmSceneName = 'SRC DM Sit/Stand';
  const sittingDmSceneItemName = 'Sit';
  let sittingDmSceneItemId;
  let isDmSitting;

  const singleSceneName = 'BASE Duo';
  let singleActivePlayer = '';
  let singleSceneItems = {
    taylor: {
      itemName: 'SRC PLYR Taylor',
      playerName: 'Taylor',
      id: undefined,
    },
    kitty: {
      itemName: 'SRC PLYR Kitty',
      playerName: 'Kitty',
      id: undefined,
    },
    sam: {
      itemName: 'SRC PLYR Sam',
      playerName: 'Sam',
      id: undefined,
    },
    josh: {
      itemName: 'SRC PLYR Miranda',
      playerName: 'Josh',
      id: undefined,
    },
  };
  const players = Object.keys(singleSceneItems);

  let scenesFiltered = [];
  let isStudioMode = false;
  const sceneIcons = JSON.parse(
    window.localStorage.getItem('sceneIcons') || '{}'
  );

  $: scenesFiltered = scenes
    .filter(
      (scene) =>
        scene.sceneName.indexOf('SRC') === -1 &&
        scene.sceneName.indexOf('DISC') === -1 &&
        scene.sceneName.indexOf('Intro') === -1 &&
        scene.sceneName.indexOf('Tech') === -1 &&
        scene.sceneName.indexOf('Trailers') === -1 &&
        scene.sceneName.indexOf('---') === -1
    )
    .reverse();
  // store sceneIcons on change
  $: window.localStorage.setItem('sceneIcons', JSON.stringify(sceneIcons));

  onMount(async function () {
    let data = await sendCommand('GetSceneList');
    console.log('GetSceneList', data);
    programScene = data.currentProgramSceneName || '';
    previewScene = data.currentPreviewSceneName;
    scenes = data.scenes;
    data = await sendCommand('GetStudioModeEnabled');
    if (data && data.studioModeEnabled) {
      isStudioMode = true;
      previewScene = data.currentPreviewSceneName || '';
    }

    // Get sitting shot scene item id
    ({ sceneItemId: sittingDmSceneItemId } = await sendCommand(
      'GetSceneItemId',
      { sceneName: sittingDmSceneName, sourceName: sittingDmSceneItemName }
    ));

    // Get DM sitting shot enabled state
    if (sittingDmSceneItemId) {
      ({ sceneItemEnabled: isDmSitting } = await sendCommand(
        'GetSceneItemEnabled',
        { sceneName: sittingDmSceneName, sceneItemId: sittingDmSceneItemId }
      ));
    }

    // Get mapCamera scene item id from OBS
    ({ sceneItemId: mapCameraSceneItemId } = await sendCommand(
      'GetSceneItemId',
      { sceneName: mapCameraSceneName, sourceName: mapCameraSceneItemName }
    ));
    // console.log('Battlecam ID: ', mapCameraSceneItemId)

    // Get mapCamera enabled state from OBS
    if (mapCameraSceneItemId) {
      ({ sceneItemEnabled: isMapCameraEnabled } = await sendCommand(
        'GetSceneItemEnabled',
        { sceneName: mapCameraSceneName, sceneItemId: mapCameraSceneItemId }
      ));
    }
    // console.log('Battlecam State: ', isMapCameraEnabled)

    // Get single shot scene item ids and states for players from OBS
    players.forEach(async (player) => {
      ({ sceneItemId: singleSceneItems[player].id } = await sendCommand(
        'GetSceneItemId',
        {
          sceneName: singleSceneName,
          sourceName: singleSceneItems[player].itemName,
        }
      ));
      if (singleSceneItems[player].id) {
        const { sceneItemEnabled: isEnabled } = await sendCommand(
          'GetSceneItemEnabled',
          {
            sceneName: singleSceneName,
            sceneItemId: singleSceneItems[player].id,
          }
        );
        if (isEnabled) {
          singleActivePlayer = player;
        }
      }
    });
  });

  obs.on('StudioModeStateChanged', async (data) => {
    console.log('StudioModeStateChanged', data.studioModeEnabled);
    isStudioMode = data.studioModeEnabled;
    previewScene = programScene;
  });

  obs.on('SceneListChanged', async (data) => {
    console.log('SceneListChanged', data.scenes.length);
    scenes = data.scenes;
  });

  obs.on('SceneCreated', async (data) => {
    console.log('SceneCreated', data);
  });

  obs.on('SceneRemoved', async (data) => {
    console.log('SceneRemoved', data);
    for (let i = 0; i < scenes.length; i++) {
      if (scenes[i].sceneName === data.sceneName) {
        delete scenes[i];
      }
    }
  });

  obs.on('SceneNameChanged', async (data) => {
    console.log('SceneNameChanged', data);
    for (let i = 0; i < scenes.length; i++) {
      if (scenes[i].sceneName === data.oldSceneName) {
        scenes[i].sceneName = data.sceneName;
      }
    }
    // Rename in sceneIcons
    sceneIcons[data.sceneName] = sceneIcons[data.oldSceneName];
  });

  obs.on('CurrentProgramSceneChanged', (data) => {
    console.log('CurrentProgramSceneChanged', data);
    programScene = data.sceneName || '';
  });

  obs.on('CurrentPreviewSceneChanged', async (data) => {
    console.log('CurrentPreviewSceneChanged', data);
    previewScene = data.sceneName;
  });

  obs.on('SceneItemEnableStateChanged', async (data) => {
    const changedScene = data.sceneName;
    const changedSceneItemId = data.sceneItemId;
    const changedState = data.sceneItemEnabled;

    switch (changedScene) {
      case mapCameraSceneName:
        if (changedSceneItemId === mapCameraSceneItemId) {
          isMapCameraEnabled = changedState;
        }
        break;
      case sittingDmSceneName:
        if (changedSceneItemId === sittingDmSceneItemId) {
          isDmSitting = changedState;
        }
        break;
      /* case singleSceneName: {
        // Todo: this in a way that doesn't break
        players.forEach((player) => {
          if (changedSceneItemId === singleSceneItems[player].id) {
            singleActivePlayer = player;
          }
        });
      } */
      default:
        break;
    }
  });

  function sceneClicker(scene) {
    return async function () {
      if (isStudioMode) {
        await sendCommand('SetCurrentPreviewScene', {
          sceneName: scene.sceneName,
        });
      } else {
        await sendCommand('SetCurrentProgramScene', {
          sceneName: scene.sceneName,
        });
      }
    };
  }

  function mapCameraClicker() {
    return async function () {
      isMapCameraEnabled = !isMapCameraEnabled;
      await sendCommand('SetSceneItemEnabled', {
        sceneName: mapCameraSceneName,
        sceneItemId: mapCameraSceneItemId,
        sceneItemEnabled: isMapCameraEnabled,
      });
    };
  }

  function singleShotPlayerClicker(newActivePlayer) {
    return async function () {
      players.forEach(async (player) => {
        const isNewActivePlayer = player === newActivePlayer;
        if (isNewActivePlayer) {
          singleActivePlayer = newActivePlayer;
        }
        await sendCommand('SetSceneItemEnabled', {
          sceneName: singleSceneName,
          sceneItemId: singleSceneItems[player].id,
          sceneItemEnabled: isNewActivePlayer,
        });
      });
    };
  }

  function sitStandClicker() {
    return async function () {
      isDmSitting = !isDmSitting;
      await sendCommand('SetSceneItemEnabled', {
        sceneName: sittingDmSceneName,
        sceneItemId: sittingDmSceneItemId,
        sceneItemEnabled: isDmSitting,
      });
    };
  }

  function onNameChange(event) {
    sendCommand('SetSceneName', {
      sceneName: event.target.title,
      newSceneName: event.target.value,
    });
  }
  function onIconChange(event) {
    sceneIcons[event.target.title] = event.target.value;
  }
</script>

<div class="meta-controls" id="misc">
  <PlayerButton
    name="MapCam: {isMapCameraEnabled ? 'On' : 'Off'}"
    on:click={mapCameraClicker()}
    isActive={!isMapCameraEnabled}
    halfWidth
  />
  <PlayerButton
    name="DM: {isDmSitting ? 'Sitting' : 'Standing'}"
    on:click={sitStandClicker()}
    isActive={!isDmSitting}
    halfWidth
  />
</div>

<div class="meta-controls" id="singles">
  {#each players as player}
    <PlayerButton
      name={singleSceneItems[player].playerName}
      on:click={singleShotPlayerClicker(player)}
      isActive={player === singleActivePlayer}
    />
  {/each}
</div>

<ol class:column={editable} class:with-icon={buttonStyle === 'icon'}>
  {#if editable}
    {#each scenes.reverse() as scene}
      <li>
        <!-- svelte-ignore a11y-label-has-associated-control -->
        <label class="label">Name</label>
        <input
          type="text"
          class="input"
          title={scene.sceneName}
          value={scene.sceneName}
          on:change={onNameChange}
        />
        <!-- svelte-ignore a11y-label-has-associated-control -->
        <label class="label">Icon</label>
        <input
          type="text"
          class="input"
          title={scene.sceneName}
          value={sceneIcons[scene.sceneName] || ''}
          on:change={onIconChange}
        />
      </li>
    {/each}
  {:else}
    {#each scenesFiltered as scene}
      <li>
        <SourceButton
          name={scene.sceneName}
          on:click={sceneClicker(scene)}
          isProgram={programScene === scene.sceneName}
          isPreview={previewScene === scene.sceneName}
          activeSingle={singleActivePlayer}
          {buttonStyle}
          icon={sceneIcons[scene.sceneName] ||
            `#${Math.floor(Math.random() * 16777215).toString(16)}`}
        />
      </li>
    {/each}
  {/if}
</ol>

<style>
  ol {
    list-style: None;
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
    gap: 0.7rem;
    margin-top: 2rem;
    margin-bottom: 2rem;
  }
  ol.column {
    flex-direction: column;
    gap: 1rem;
  }
  li {
    display: inline-block;
    min-width: 10rem;
    flex-grow: 1;
  }
  ol.with-icon {
    justify-content: center;
  }
  ol.with-icon li {
    min-width: 0;
    flex-grow: 0;
    flex-shrink: 1;
  }
  .meta-controls {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-between;
    gap: 0.5rem;
    margin-bottom: 0rem;
  }
</style>
